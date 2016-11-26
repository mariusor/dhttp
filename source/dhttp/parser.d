module dhttp.parser;

import std.string;
import std.stdio;
import std.conv;
import std.range.primitives;
import dhttp.request;
import std.algorithm.iteration;

class Parser
{
    class HeaderParser {
    
        static void parse(Request r, char[][] headers) {
            auto current_size = r.headers.length;
            auto new_size = headers.length;

            r.headers.length = current_size + new_size;
            for(ushort i = 0; i < new_size; i++) {
                auto elements = splitter(headers[i], ':');

                Header h = new Header;
                h.name = to!string(elements.front);
                elements.popFront();
                h.value = to!string(elements.front);

                r.headers[current_size+i] = h;    
            }
        }
    }

    class BodyParser {
        static void parse(Request req, char[] req_body)
        {
            req.req_body = cast(ubyte[]) req_body;
        }
    }

    class RequestParser {
         // parses the full request

        static string split = "\r\n\r\n";


        static void parse(Request req, char[] raw_request) 
        {
            if (raw_request.length == 0) {
                return;
            }
            auto components = splitter(raw_request, RequestParser.split);

            auto request = components.front;
            components.popFront();
            auto req_body = components.front;
             
            //string buffered_line = (cast(immutable(char)*)buffer)[0..buffer.length]; 
            auto lines = request.splitLines();

            if (!lines.empty()) {
                auto first_line = lines.front;
                auto tokens = splitter(first_line, ' ');
               
                if (!tokens.empty()) {
                    setType(req, tokens.front); 
                    tokens.popFront();

                    setPath(req, tokens.front); 
                    tokens.popFront();

                    setVersion(req, tokens.front); 
                }
                lines.popFront();

                HeaderParser.parse(req, lines);
                BodyParser.parse(req, req_body);
            }
        }

        static void setType(Request r, char[] req_type) {
            switch (req_type) {
                default: r.method = HTTPMethod.GET; break;
                case "GET": r.method = HTTPMethod.GET; break;
                case "HEAD": r.method = HTTPMethod.HEAD; break;
                case "PUT": r.method = HTTPMethod.PUT; break;
                case "POST": r.method = HTTPMethod.POST; break;
                case "PATCH": r.method = HTTPMethod.PATCH; break;
                case "DELETE": r.method = HTTPMethod.DELETE; break;
                case "OPTIONS": r.method = HTTPMethod.OPTIONS; break;
                case "TRACE": r.method = HTTPMethod.TRACE; break;
                case "CONNECT": r.method = HTTPMethod.CONNECT; break;

                // WEBDAV extensions, RFC 2518
                case "PROPFIND": r.method = HTTPMethod.PROPFIND; break;
                case "PROPPATCH": r.method = HTTPMethod.PROPPATCH; break;
                case "MKCOL": r.method = HTTPMethod.MKCOL; break;
                case "COPY": r.method = HTTPMethod.COPY; break;
                case "MOVE": r.method = HTTPMethod.MOVE; break;
                case "LOCK": r.method = HTTPMethod.LOCK; break;
                case "UNLOCK": r.method = HTTPMethod.UNLOCK; break;

                // Versioning Extensions to WebDAV, RFC 3253
                case "VERSION-CONTROL": r.method = HTTPMethod.VERSIONCONTROL; break;
                case "REPORT": r.method = HTTPMethod.REPORT; break;
                case "CHECKOUT": r.method = HTTPMethod.CHECKOUT; break;
                case "CHECKIN": r.method = HTTPMethod.CHECKIN; break;
                case "UNCHECKOUT": r.method = HTTPMethod.UNCHECKOUT; break;
                case "MKWORKSPACE": r.method = HTTPMethod.MKWORKSPACE; break;
                case "UPDATE": r.method = HTTPMethod.UPDATE; break;
                case "LABEL": r.method = HTTPMethod.LABEL; break;
                case "MERGE": r.method = HTTPMethod.MERGE; break;
                case "BASELINE-CONTROL": r.method = HTTPMethod.BASELINECONTROL; break;
                case "MKACTIVITY": r.method = HTTPMethod.MKACTIVITY; break;

                // Ordered Collections Protocol, RFC 3648
                case "ORDERPATCH": r.method = HTTPMethod.ORDERPATCH; break;

                // Access Control Protocol, RFC 3744
                case "ACL": r.method = HTTPMethod.ACL; break;
            }
        }

        static void setVersion(Request r, char[] req_version) {
            auto tokens = splitter(req_version, '/');
            tokens.popFront();
            auto ver = to!string(tokens.front);

            r.http_version = to!ushort(to!float(ver) * 100);
        }

        static void setPath(Request r, char[] req_path) {
            r.path = (cast(string)req_path)[0..req_path.length];
        }
    }

    static Request parse(char[] buffer) 
    {
        Request r = new Request;          
        RequestParser.parse(r, buffer);
        return r;
    }

    
    static bool validHTTP(char[] buff) 
    {
        ushort last_pos = 0;
        switch (buff[0]) {
            case 'G':
                // possible get
                if (buff[0..4] == "GET ") {
                    last_pos = 4;
                    break;
                }
                return false;
            case 'H':
                if (buff[0..5] == "HEAD ") {
                    last_pos = 5;
                    break;
                }
                return false;
            case 'P':
                if (buff[0..5] == "POST ") {
                    last_pos = 5;
                    break;
                }
                if (buff[0..4] == "PUT ") {
                    last_pos = 4;
                    break;
                }
                return false;
            case 'D':
                if (buff[0..7] == "DELETE ") {
                    last_pos = 7;
                    break;
                }
                return false;
            default:
                return false;
        }

        if (buff[last_pos] != '/') return false;
        for (ushort i = last_pos; i++; i < buff.length) {
            if (buff[i] == ' ') {
                last_pos = i;
                last_pos++;
                break;
            }
        }
        char[8] ver = buff[last_pos..last_pos+8]; 
        if (ver != "HTTP/1.0" && ver != "HTTP/1.1" && ver != "HTTP/2.0") {
            return false;
        }
        return true;
    }
}
