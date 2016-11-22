module dhttp.request;

import std.string;
import std.conv;

class Header 
{
    string name;
    string value;

    override string toString()
    {
        return name ~ ": " ~ value;
    }
}

class Request
{
    const ushort HTTP_1_0 = 100;
    const ushort HTTP_1_1 = 110;
    const ushort HTTP_2_0 = 200;

    enum Type {
        GET,
        POST,
        HEAD,
        PUT,
        DELETE,
        PATCH
    };

    string protocol = "HTTP";
    string path;
    Header[] headers;
    ubyte[] req_body;
    ushort http_version = 0;
    Type method;

    bool isEmpty()
    {
        return (http_version == 0);
    }

    override string toString() 
    {
        if (isEmpty()) {
            return "NULL REQ"; 
        }

        auto version_label = http_version == HTTP_1_1 ? "1.1" : "1.0";
        auto method_label = "GET";

        if (method == Type.POST) method_label = "POST";
        if (method == Type.HEAD) method_label = "HEAD";
        if (method == Type.PUT) method_label = "PUT"; 
        if (method == Type.DELETE) method_label = "DELETE";
        if (method == Type.PATCH) method_label = "PATCH";

//        auto header_string = "";
//        if (headers.length > 0) {
//            header_string ~= "\n";
//            for (int i = 0; i < headers.length; i++) {
//                header_string ~= headers[i].toString() ~ "\n";
//            }
//        }

        return (protocol ~ "/" ~ version_label ~ " " ~ method_label ~ " " ~ path);
    }

}
