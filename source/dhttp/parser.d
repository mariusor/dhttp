module dhttp.parser;

import std.string;
import std.stdio;
import std.conv;
import dhttp.request;
import std.algorithm.iteration;
import std.algorithm : remove;

class Parser
{
    class HeaderParser {}
    class BodyParser {}
    class RequestParser {
         // parses the full request

        static char[4] split = "\r\n\r\n";

        static Request parse(char[] raw_request) 
        {
            //auto components = std.algorithm.findSplitBefore(raw_request, RequestParser.split);

//            auto components = splitter!(a => a == RequestParser.split)(raw_request);
//            writefln(components);
//
            return new Request();
        }
    }

    static Request parse(char[] buffer) 
    {
        auto rr = RequestParser.parse(buffer);


        string buffered_line = (cast(immutable(char)*)buffer)[0..buffer.length]; 
        auto lines = splitLines(buffered_line);
        Request r = new Request;          

        if (!lines.empty()) {
            auto first_line = lines[0];
            auto tokens = splitter(first_line, ' ');
           
            if (!tokens.empty()) {
                setType(r, tokens.front); 
                tokens.popFront();
                setPath(r, tokens.front); 
                tokens.popFront();
                setVersion(r, tokens.front); 
            }
            lines = lines.remove(0);

            auto components = splitter!(a => a.empty() == true)(lines);
            auto headers = components.front;
            //writefln("%s", headers);
            setHeaders(r, headers);

            components.popFront();
            auto content = components.front;
            //writefln("%s", content);
        }
        return r;
    }

    static void setType(Request r, string req_type) {
        if (req_type == "GET") {
            r.method = Request.Type.GET;
        }
        if (req_type == "HEAD") {
            r.method = Request.Type.HEAD;
        }
        if (req_type == "POST") {
            r.method = Request.Type.POST;
        }
        if (req_type == "PUT") {
            r.method = Request.Type.PUT;
        }
        if (req_type == "DELETE") {
            r.method = Request.Type.DELETE;
        }
        if (req_type == "PATCH") {
            r.method = Request.Type.PATCH;
        }
    }

    static void setVersion(Request r, string req_version) {
        auto tokens = splitter(req_version, '/');
        auto decimal_version = to!float(tokens.back);

        r.protocol = tokens.front;
        r.http_version = to!ushort(decimal_version * 100);
    }

    static void setPath(Request r, string req_path) {
        r.path = req_path;
    }
    
    static void setHeaders(Request r, string[] headers) {
        auto current_size = r.headers.length;
        auto new_size = headers.length;

        r.headers.length = current_size + new_size;
        for(ushort i = 0; i < new_size; i++) {
            auto elements = splitter(headers[i], ':');

            auto _name = elements.front;
            elements.popFront();
            auto _value = elements.front;
            Header h = new Header;
            h.name = _name;
            h.value = _value;

            r.headers[current_size+i] = h;    
        }
    }
}
