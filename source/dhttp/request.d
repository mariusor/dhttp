module dhttp.request;

import std.string;
import std.conv;

enum HTTPVersion {
	HTTP_1_0,
	HTTP_1_1,
	HTTP_2_0
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
    string path;
    Header[] headers;
    ubyte[] req_body;
    ushort http_version = 0;
    HTTPMethod method;

    bool isEmpty()
    {
        return (http_version == 0);
    }

    override string toString() 
    {
        if (isEmpty()) return "empty req";

        auto version_label = http_version == HTTPVersion.HTTP_1_1 ? "1.1" : "1.0";
        return ("HTTP/" ~ version_label ~ " " ~ to!string(method) ~ " " ~ path);
    }

}
