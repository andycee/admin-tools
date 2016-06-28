import poplib
import email

server = "10.0.14.1"
port = "110"
login = "koroban@kaiserhof.heliopark.ru"
password = "12345asdF"

box = poplib.POP3(server, port)
box.user(login)
box.pass_(password)

response, lst, octets = box.list()
print "Total %s messages: %s" % (login, len(lst))

for msgnum, msgsize in [i.split() for i in lst]:
    (resp, lines, octetc) = box.retr(msgnum)
    msgtext = "\n".join(lines)
    message = email.message_from_string(msgtext)
    parser = email.parser.HeaderParser()
    headers = parser.parsestr(msgtext, True)
    for h in headers.items():
        if h[0] == "Return-Path" or h[0] == "Message-ID":
            print h

box.quit()
