import std.socket;
import dhttp.server;

int main()
{
    Server s = new Server(8080, 3);

    while(true) 
        s.listen();
}
