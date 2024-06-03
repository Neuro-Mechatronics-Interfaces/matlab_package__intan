function enableDigIn(intanTcpClient)
write(intanTcpClient, uint8('set DIGITAL-IN-1.enabled true'));
write(intanTcpClient, uint8('set DIGITAL-IN-1.recordingenabled true'));
write(intanTcpClient, uint8('set DIGITAL-IN-2.enabled true'));
write(intanTcpClient, uint8('set DIGITAL-IN-2.recordingenabled true'));
end