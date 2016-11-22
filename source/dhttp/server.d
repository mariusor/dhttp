module dhttp.server;

import dhttp.parser;
import dhttp.request;
import std.socket : InternetAddress, Socket, SocketException, SocketSet, TcpSocket, SocketOptionLevel, SocketOption, SocketShutdown;
import std.experimental.logger;
import std.algorithm : remove;
import std.algorithm.comparison : equal;


class Server
{
    enum MAX_CONNECTIONS = 60;
    enum MAX_BUF_SIZE = 4194304;

    short sock_number = 1;

    SocketSet socket_set;
    Socket listener;
    Socket[] pool;

    this(ushort port = 8080, ushort socket_count = 10) {
        sock_number = socket_count;

        listener = new TcpSocket();
        assert(listener.isAlive);
        listener.blocking = false;
        listener.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

        auto ipv4 = new InternetAddress("127.0.0.1", port);
        //auto ipv6 = new Internet6Address("::1", port);
        listener.bind(ipv4);
        listener.listen(10);
        logf("Listening on %s", ipv4.toString());
        //try {
        //    listener.bind(ipv6);
        //    logf("Listening on %s", ipv6.toString());
        //} catch (SocketOSException e) {
        //   errorf("Unable to listen on %s", ipv6.toString()); 
        //}

        socket_set = new SocketSet(socket_count + 1);
    }

    char[] drain_socket (Socket socket) 
    {
        enum BUFF_SIZE = 1024;
        char[] full_buffer;
        while (true) {
            char[BUFF_SIZE] buffer;

            auto received = socket.receive(buffer);
            if (received > 0) {
                full_buffer ~= buffer[0..received];
                tracef("Received %d bytes", received);
            }
            if (received < BUFF_SIZE || received == 0) {
                // client closed connection or read less than buffer size
                try {
                    // if the connection closed due to an error, remoteAddress() could fail
                    infof("Connection from %s closed.", socket.remoteAddress().toString());
                } catch (SocketException) {
                    infof("Connection closed.");
                }
                break;
            }
            if (received == Socket.ERROR) {
                error("Connection error");
                break;
            }
        }

        return full_buffer;
    }

    int listen () {
        socket_set.add(listener);

        foreach (sock; pool) {
            socket_set.add(sock);
        }

        Socket.select(socket_set, null, null);
        for (size_t i = 0; i < pool.length; i++) {
            if (socket_set.isSet(pool[i])) {
                char[] buffer = drain_socket(pool[i]);

                infof("Received %d bytes from %s", buffer.length, pool[i].remoteAddress().toString());
                Request request = Parser.parse(buffer);
                logf("%s", request);
                // logf("%s", request.headers);

                enum header = "HTTP/1.0 200 OK\nContent-Type: text/plain; charset=utf-8\n\n";

                string response = header ~ "Hello World!\n";

                pool[i].send(response);
                pool[i].shutdown(SocketShutdown.BOTH);
                pool[i].close();
                pool = pool.remove(i);
                infof("Connections %d", pool.length);
            }

        }


        if (socket_set.isSet(listener)) {
            Socket sn = null;
            scope (failure) {
                error("Error reading socket");

                if (sn)
                    sn.close();
            }

            sn = listener.accept();
            assert(sn.isAlive);
            assert(listener.isAlive);

            if (pool.length < MAX_CONNECTIONS) {
                infof("Connection from %s established.", sn.remoteAddress().toString());
                pool ~= sn;
                infof("Connections %d", pool.length);
            } else {
                warningf("Rejected connection from %s; too many connections", sn.remoteAddress().toString());
                sn.close();
                assert(!sn.isAlive);
                assert(listener.isAlive);
            }

        }
        socket_set.reset();
        return 1;
    }
}
