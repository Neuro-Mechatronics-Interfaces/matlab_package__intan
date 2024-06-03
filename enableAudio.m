function enableAudio(intanTcpClient)
write(intanTcpClient, uint8('set audioenabled true'));
write(intanTcpClient, uint8('set audiofilter high'));
write(intanTcpClient, uint8('set analogout1locktoselected true'));
end