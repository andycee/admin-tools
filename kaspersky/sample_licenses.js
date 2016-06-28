/*!
 * (C) 2008 Kaspersky Lab 
 * 
 * \file	sample_licenses.js
 * \brief	Code sample. Enumerating license keys. 
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


function Start()
{
    var oAdmServer = AcquireAdServerProxy("localhost:13000");

    var oLicenses = new ActiveXObject("klakaut.KlAkLicense");
    oLicenses.AdmServer = oAdmServer;
    
    // Enumerate keys
    
    var oFileds2Return = new ActiveXObject("klakaut.KlAkCollection");
    oFileds2Return.SetSize(14);
    oFileds2Return.SetAt(0, "KLLIC_APP_ID");
    oFileds2Return.SetAt(1, "KLLIC_PROD_SUITE_ID");
    oFileds2Return.SetAt(2, "KLLIC_LIMIT_DATE");
    oFileds2Return.SetAt(3, "KLLIC_SERIAL");
    oFileds2Return.SetAt(4, "KLLIC_PROD_NAME");
    oFileds2Return.SetAt(5, "KLLIC_KEY_TYPE");
    oFileds2Return.SetAt(6, "KLLIC_MAJ_VER");
    oFileds2Return.SetAt(7, "KLLIC_LICENSE_PERIOD");
    oFileds2Return.SetAt(8, "KLLIC_LIC_COUNT");
    oFileds2Return.SetAt(9, "KLLICSRV_KEY_INSTALLED");
    oFileds2Return.SetAt(11, "KLLIC_LICINFO");
    oFileds2Return.SetAt(12, "KLLIC_SUPPORT_INFO");
    oFileds2Return.SetAt(13, "KLLIC_CUSTOMER_INFO");
    
    var oFileds2Order = new ActiveXObject("klakaut.KlAkCollection");
    
    var oOptions = new ActiveXObject("klakaut.KlAkParams");
    
    var oChunkAccessor = oLicenses.EnumKeys(
                            oFileds2Return,
                            oFileds2Order,
                            oOptions);

    var enumObj = new Enumerator(oChunkAccessor);
    for (;!enumObj.atEnd();enumObj.moveNext())
    {
        var oObj = enumObj.item();
        
        g_oLog.WriteLine("______________________");
        g_oLog.WriteLine("KLLIC_APP_ID: " + oObj.Item("KLLIC_APP_ID"));
        g_oLog.WriteLine("KLLIC_PROD_SUITE_ID: " + oObj.Item("KLLIC_PROD_SUITE_ID"));
        g_oLog.WriteLine("KLLIC_SERIAL: " + oObj.Item("KLLIC_SERIAL"));
        g_oLog.WriteLine("KLLIC_PROD_NAME: " + oObj.Item("KLLIC_PROD_NAME"));
        g_oLog.WriteLine("KLLICSRV_KEY_INSTALLED: " + oObj.Item("KLLICSRV_KEY_INSTALLED"));
        g_oLog.WriteLine("______________________");        
        
    };
    
    
};

var g_oFileSystemObject;
var g_oLog;

// prepare logging
g_oFileSystemObject = new ActiveXObject("Scripting.FileSystemObject");
g_oLog = g_oFileSystemObject.CreateTextFile("log.txt", true);

Start();

g_oLog.Close();
