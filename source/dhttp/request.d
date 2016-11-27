module dhttp.request;

import std.string;
import std.conv;

unittest {

    assert(to!string(HTTPVersion.HTTP_1_0) == "HTTP_1_0");
    assert(to!string(HTTPVersion.HTTP_1_1) == "HTTP_1_1");
    assert(to!string(HTTPVersion.HTTP_2_0) == "HTTP_2_0");
}

enum HTTPVersion : ushort {
	HTTP_1_0 = 100,
	HTTP_1_1 = 110,
	HTTP_2_0 = 200
}

unittest {
    assert(to!string(HTTPMethod.GET) == "GET");
    assert(to!string(HTTPMethod.HEAD) == "HEAD");
    assert(to!string(HTTPMethod.PUT) == "PUT");
    assert(to!string(HTTPMethod.POST) == "POST");
    assert(to!string(HTTPMethod.PATCH) == "PATCH");
    assert(to!string(HTTPMethod.DELETE) == "DELETE");
    assert(to!string(HTTPMethod.OPTIONS) == "OPTIONS");
    assert(to!string(HTTPMethod.TRACE) == "TRACE");
    assert(to!string(HTTPMethod.CONNECT) == "CONNECT");
}

enum HTTPMethod {
	// HTTP standard, RFC 2616
	GET,
	HEAD,
	PUT,
	POST,
	PATCH,
	DELETE,
	OPTIONS,
	TRACE,
	CONNECT,

	// WEBDAV extensions, RFC 2518
	PROPFIND,
	PROPPATCH,
	MKCOL,
	COPY,
	MOVE,
	LOCK,
	UNLOCK,

	// Versioning Extensions to WebDAV, RFC 3253
	VERSIONCONTROL,
	REPORT,
	CHECKOUT,
	CHECKIN,
	UNCHECKOUT,
	MKWORKSPACE,
	UPDATE,
	LABEL,
	MERGE,
	BASELINECONTROL,
	MKACTIVITY,

	// Ordered Collections Protocol, RFC 3648
	ORDERPATCH,

	// Access Control Protocol, RFC 3744
	ACL
}

unittest {
    string buff = "Host: example.com";
    Header h = new Header;
    h.name = "Host";
    h.value = "example.com";
    assert (h.toString() == buff);
}

class Header 
{
    string name;
    string value;

    override string toString()
    {
        return name ~ ": " ~ value;
    }
}

unittest {
    Header h = new Header;
    h.name = "Host";
    h.value = "example.com";

    Request r = new Request;

    r.path = "/";
    r.headers ~= h;

    r.http_version = HTTPVersion.HTTP_1_1;
    r.method = HTTPMethod.PUT;

    assert (r.path == "/");
    assert (r.headers.length == 1);
    assert (r.headers[0].name == "Host");
    assert (r.headers[0].value == "example.com");
    assert (r.http_version == HTTPVersion.HTTP_1_1);
    assert (r.req_body.length == 0);
    assert (r.req_body == "");
}

class Request
{
    string path;
    Header[] headers;
    ubyte[] req_body;
    HTTPVersion http_version;
    HTTPMethod method;

    bool isEmpty()
    {
        return (path.length == 0);
    }

    override string toString() 
    {
        if (isEmpty()) return "empty req";

        auto version_label = http_version == HTTPVersion.HTTP_1_1 ? "1.1" : "1.0";
        return ("HTTP/" ~ version_label ~ " " ~ to!string(method) ~ " " ~ path);
    }

}
