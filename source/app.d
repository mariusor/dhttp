import std.socket;
import std.parallelism;
import dhttp.server;

int main()
{
    Server s = new Server(8080, 3);

    //HTTPListen(s);
    auto task = task!HTTPListen(s);
    task.executeInNewThread();

    return 0;
}
