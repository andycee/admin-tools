/*!
 * (C) 2007 Kaspersky Lab 
 * 
 * \file	sample_task.js
 * \brief	Code sample. Enumerating tasks, querying task statistics and running task. 
 * 
 * Finds "global task" with name "Test task", starts it and waits until 
 * it completes at least for one host
 *
 */

function AcquireAdServerProxy(strAddress)
{    
    var oSrvConnectionProps = new ActiveXObject("klakaut.KlAkParams");
    oSrvConnectionProps.Add("Address", strAddress);
    oSrvConnectionProps.Add("UseSSL", true);
    
    var oAdmServer = new ActiveXObject("klakaut.KlAkProxy");
    oAdmServer.Connect(oSrvConnectionProps);
    g_oLog.WriteLine("Server version is " + oAdmServer.VersionId);
    return oAdmServer;
};

function FindTask(oTasks, strDisplayName)
{
    var strResult = "";
    oData = oTasks.EnumTasks(-1);
    enumObj = new Enumerator(oData);
    for(;!enumObj.atEnd();enumObj.moveNext()) 
    {
        oItem = enumObj.item();
        var strDN = oItem.Item("DisplayName");
        
        g_oLog.WriteLine("Task " + strDN + " found");

        if( strDN == strDisplayName )
        {
            strResult = oItem.Item("TASK_UNIQUE_ID");
            break;
        };
    };
    return strResult;
};

function GetLastTaskResult(oTasks, strID)
{
    //fill object with required fields
    var oFields2Return = new ActiveXObject("klakaut.KlAkCollection");
    oFields2Return.SetSize(4);
    oFields2Return.SetAt(0, "event_type");
    oFields2Return.SetAt(1, "task_new_state");
    oFields2Return.SetAt(2, "event_id");
    oFields2Return.SetAt(3, "rise_time");

    //sort descending by publication time
    var oSortItem = new ActiveXObject("klakaut.KlAkParams");
    oSortItem.Item("Name") = "rise_time";
    oSortItem.Item("Asc") = false;

    var oSortFields = new ActiveXObject("klakaut.KlAkCollection");
    oSortFields.SetSize(1);
    oSortFields.SetAt(0, oSortItem);

    //we need only task state events
    var oFilter = new ActiveXObject("klakaut.KlAkParams");
    oFilter.Item("event_type") = "KLPRCI_TaskState";

    var oHistory = oTasks.GetTaskHistory(strID, oFields2Return, oSortFields, "", oFilter);

    var enumObj = new Enumerator(oHistory);

    var oResult;

    for (;!enumObj.atEnd();enumObj.moveNext())
    {
        var oObj = enumObj.item();

        g_oLog.WriteLine("--- event --");
        g_oLog.WriteLine( "event_id: " + oObj.Item("event_id"));
        g_oLog.WriteLine( "event_type: " + oObj.Item("event_type"));
        g_oLog.WriteLine( "task_new_state: " + oObj.Item("task_new_state"));
        g_oLog.WriteLine( "rise_time: " + oObj.Item("rise_time"));
        g_oLog.WriteLine( " ");

        var nState = oObj.Item("task_new_state");
        if( 3 == nState || 4 == nState ) // if failed or completed successfully
        {
            oResult = oObj;
            break;
        };
    };

    return oResult;
};

//    starts task and waits until it completes at least for one host, 
//    returns task result for this host (3 -- failed, 4 -- succeeded)
function RunTaskAndReturnResult(oTasks, strID)
{
    oInfo = oTasks.GetTask(strID);
    g_oLog.WriteLine(   "Processing task " + 
                            oInfo.Item("DisplayName") + 
                            " created at " + 
                            oInfo.Item("PRTS_TASK_CREATION_DATE") );
    
    // print task statistics into the log
    var oStatistics = oTasks.GetTaskStatistics(strID);

    g_oLog.WriteLine( "Task statistics" );
    g_oLog.WriteLine( "Not distributed: " + oStatistics.Item("1"));
    g_oLog.WriteLine( "Running: " + oStatistics.Item("2"));
    g_oLog.WriteLine( "OK: " + oStatistics.Item("4"));
    g_oLog.WriteLine( "Warning: " + oStatistics.Item("8"));
    g_oLog.WriteLine( "Failed: " + oStatistics.Item("16"));
    g_oLog.WriteLine( "Scheduled: " + oStatistics.Item("32"));
    g_oLog.WriteLine( "Paused: " + oStatistics.Item("64"));

    //initial task state (before task start)
    var oState0 = GetLastTaskResult(oTasks, strID);

    oTasks.RunTask( strID );

    // wait for a 5 seconds
    WScript.Sleep(5000);

    var nResult;
    while(true)
    {
        var oState1 = GetLastTaskResult(oTasks, strID);
        if( ( undefined == oState0  && undefined != oState1) ||
            ( undefined != oState1 && 
              undefined != oState0 && 
              oState1.Item("event_id") != oState0.Item("event_id")
            )  
          )
        {
            g_oLog.WriteLine("Task result is " + oState1.Item("task_new_state"));
            nResult = oState1.Item("task_new_state");
            g_oLog.WriteLine( " ");
            break;
        };
        WScript.Sleep(5000);
    };

    // return final task state (before task start)
    return nResult;
};

function Start()
{
    var oAdmServer = AcquireAdServerProxy("localhost:13000");

    var oTasks = new ActiveXObject("klakaut.KlAkTasks");
    oTasks.AdmServer = oAdmServer;

    var strInterestingTaskName = "Test task";
    var strFoundTask = FindTask(oTasks, strInterestingTaskName);
    if( "" != strFoundTask )
    {
        var nResult = RunTaskAndReturnResult(oTasks, strFoundTask);
        g_oLog.WriteLine("Task result is " + ((4 == nResult) ? "Success" : "Failure")  );
    }
    else
    {
        g_oLog.WriteLine("Task " + strInterestingTaskName + " not found");
    };
};

var g_oFileSystemObject;
var g_oLog;

// prepare logging
g_oFileSystemObject = new ActiveXObject("Scripting.FileSystemObject");
g_oLog = g_oFileSystemObject.CreateTextFile("log.txt", true);

Start();

g_oLog.Close();
