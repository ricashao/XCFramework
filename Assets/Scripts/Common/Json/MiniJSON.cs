/*
 * Copyright (c) 2013 Calvin Rien
 *
 * Based on the JSON parser by Patrick van Bergen
 * http://techblog.procurios.nl/k/618/news/view/14605/14863/How-do-I-write-my-own-parser-for-JSON.html
 *
 * Simplified it so that it doesn't throw exceptions
 * and can be used in Unity iPhone with maximum code stripping.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace MiniJSON
{
    // Example usage:
    //
    //  using UnityEngine;
    //  using System.Collections;
    //  using System.Collections.Generic;
    //  using MiniJSON;
    //
    //  public class MiniJSONTest : MonoBehaviour {
    //      void Start () {
    //          var jsonString = "{ \"array\": [1.44,2,3], " +
    //                          "\"object\": {\"key1\":\"value1\", \"key2\":256}, " +
    //                          "\"string\": \"The quick brown fox \\\"jumps\\\" over the lazy dog \", " +
    //                          "\"unicode\": \"\\u3041 Men\u00fa sesi\u00f3n\", " +
    //                          "\"int\": 65536, " +
    //                          "\"float\": 3.1415926, " +
    //                          "\"bool\": true, " +
    //                          "\"null\": null }";
    //
    //          var dict = Json.Deserialize(jsonString) as Dictionary<string,object>;
    //
    //          Debug.Log("deserialized: " + dict.GetType());
    //          Debug.Log("dict['array'][0]: " + ((List<object>) dict["array"])[0]);
    //          Debug.Log("dict['string']: " + (string) dict["string"]);
    //          Debug.Log("dict['float']: " + (double) dict["float"]); // floats come out as doubles
    //          Debug.Log("dict['int']: " + (long) dict["int"]); // ints come out as longs
    //          Debug.Log("dict['unicode']: " + (string) dict["unicode"]);
    //
    //          var str = Json.Serialize(dict);
    //
    //          Debug.Log("serialized: " + str);
    //      }
    //  }

    /// <summary>
    /// This class encodes and decodes JSON strings.
    /// Spec. details, see http://www.json.org/
    ///
    /// JSON uses Arrays and Objects. These correspond here to the datatypes IList and IDictionary.
    /// All numbers are parsed to doubles.
    /// </summary>
    public static class Json
    {
        /// <summary>
        /// Parses the string json into a value
        /// </summary>
        /// <param name="json">A JSON string.</param>
        /// <returns>An List&lt;object&gt;, a Dictionary&lt;string, object&gt;, a double, an integer,a string, null, true, or false</returns>
        public static object Deserialize(string json)
        {
            // save the string for debug information
            if (json == null)
            {
                return null;
            }

            return Parser.Parse(json);
        }

        sealed class Parser : IDisposable
        {
            const string WORD_BREAK = "{}[],:\"";

            public static bool IsWordBreak(char c)
            {
                return Char.IsWhiteSpace(c) || WORD_BREAK.IndexOf(c) != -1;
            }

            enum TOKEN
            {
                NONE,
                CURLY_OPEN,
                CURLY_CLOSE,
                SQUARED_OPEN,
                SQUARED_CLOSE,
                COLON,
                COMMA,
                STRING,
                NUMBER,
                TRUE,
                FALSE,
                NULL
            };

            StringReader json;

            Parser(string jsonString)
            {
                json = new StringReader(jsonString);
            }

            public static object Parse(string jsonString)
            {
                using (var instance = new Parser(jsonString))
                {
                    return instance.ParseValue();
                }
            }

            public void Dispose()
            {
                json.Dispose();
                json = null;
            }

            Dictionary<string, object> ParseObject()
            {
                Dictionary<string, object> table = new Dictionary<string, object>();

                // ditch opening brace
                json.Read();

                // {
                while (true)
                {
                    switch (NextToken)
                    {
                        case TOKEN.NONE:
                            return null;
                        case TOKEN.COMMA:
                            continue;
                        case TOKEN.CURLY_CLOSE:
                            return table;
                        default:
                            // name
                            string name = ParseString();
                            if (name == null)
                            {
                                return null;
                            }

                            // :
                            if (NextToken != TOKEN.COLON)
                            {
                                return null;
                            }

                            // ditch the colon
                            json.Read();

                            // value
                            table[name] = ParseValue();
                            break;
                    }
                }
            }

            List<object> ParseArray()
            {
                List<object> array = new List<object>();

                // ditch opening bracket
                json.Read();

                // [
                var parsing = true;
                while (parsing)
                {
                    TOKEN nextToken = NextToken;

                    switch (nextToken)
                    {
                        case TOKEN.NONE:
                            return null;
                        case TOKEN.COMMA:
                            continue;
                        case TOKEN.SQUARED_CLOSE:
                            parsing = false;
                            break;
                        default:
                            object value = ParseByToken(nextToken);

                            array.Add(value);
                            break;
                    }
                }

                return array;
            }

            object ParseValue()
            {
                TOKEN nextToken = NextToken;
                return ParseByToken(nextToken);
            }

            object ParseByToken(TOKEN token)
            {
                switch (token)
                {
                    case TOKEN.STRING:
                        return ParseString();
                    case TOKEN.NUMBER:
                        return ParseNumber();
                    case TOKEN.CURLY_OPEN:
                        return ParseObject();
                    case TOKEN.SQUARED_OPEN:
                        return ParseArray();
                    case TOKEN.TRUE:
                        return true;
                    case TOKEN.FALSE:
                        return false;
                    case TOKEN.NULL:
                        return null;
                    default:
                        return null;
                }
            }

            string ParseString()
            {
                StringBuilder s = new StringBuilder();
                char c;

                // ditch opening quote
                json.Read();

                bool parsing = true;
                while (parsing)
                {
                    if (json.Peek() == -1)
                    {
                        parsing = false;
                        break;
                    }

                    c = NextChar;
                    switch (c)
                    {
                        case '"':
                            parsing = false;
                            break;
                        case '\\':
                            if (json.Peek() == -1)
                            {
                                parsing = false;
                                break;
                            }

                            c = NextChar;
                            switch (c)
                            {
                                case '"':
                                case '\\':
                                case '/':
                                    s.Append(c);
                                    break;
                                case 'b':
                                    s.Append('\b');
                                    break;
                                case 'f':
                                    s.Append('\f');
                                    break;
                                case 'n':
                                    s.Append('\n');
                                    break;
                                case 'r':
                                    s.Append('\r');
                                    break;
                                case 't':
                                    s.Append('\t');
                                    break;
                                case 'u':
                                    var hex = new char[4];

                                    for (int i = 0; i < 4; i++)
                                    {
                                        hex[i] = NextChar;
                                    }

                                    s.Append((char) Convert.ToInt32(new string(hex), 16));
                                    break;
                            }

                            break;
                        default:
                            s.Append(c);
                            break;
                    }
                }

                return s.ToString();
            }

            object ParseNumber()
            {
                string number = NextWord;

                if (number.IndexOf('.') == -1 && number.IndexOf('E') == -1 && number.IndexOf('e') == -1)
                {
                    long parsedInt;
                    Int64.TryParse(number, System.Globalization.NumberStyles.Any,
                        System.Globalization.CultureInfo.InvariantCulture, out parsedInt);
                    return parsedInt;
                }

                double parsedDouble;
                Double.TryParse(number, System.Globalization.NumberStyles.Any,
                    System.Globalization.CultureInfo.InvariantCulture, out parsedDouble);
                return parsedDouble;
            }

            void EatWhitespace()
            {
                while (Char.IsWhiteSpace(PeekChar))
                {
                    json.Read();

                    if (json.Peek() == -1)
                    {
                        break;
                    }
                }
            }

            char PeekChar
            {
                get { return Convert.ToChar(json.Peek()); }
            }

            char NextChar
            {
                get { return Convert.ToChar(json.Read()); }
            }

            string NextWord
            {
                get
                {
                    StringBuilder word = new StringBuilder();

                    while (!IsWordBreak(PeekChar))
                    {
                        word.Append(NextChar);

                        if (json.Peek() == -1)
                        {
                            break;
                        }
                    }

                    return word.ToString();
                }
            }

            TOKEN NextToken
            {
                get
                {
                    EatWhitespace();

                    if (json.Peek() == -1)
                    {
                        return TOKEN.NONE;
                    }

                    switch (PeekChar)
                    {
                        case '{':
                            return TOKEN.CURLY_OPEN;
                        case '}':
                            json.Read();
                            return TOKEN.CURLY_CLOSE;
                        case '[':
                            return TOKEN.SQUARED_OPEN;
                        case ']':
                            json.Read();
                            return TOKEN.SQUARED_CLOSE;
                        case ',':
                            json.Read();
                            return TOKEN.COMMA;
                        case '"':
                            return TOKEN.STRING;
                        case ':':
                            return TOKEN.COLON;
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                        case '8':
                        case '9':
                        case '-':
                            return TOKEN.NUMBER;
                    }

                    switch (NextWord)
                    {
                        case "false":
                            return TOKEN.FALSE;
                        case "true":
                            return TOKEN.TRUE;
                        case "null":
                            return TOKEN.NULL;
                    }

                    return TOKEN.NONE;
                }
            }
        }

        /// <summary>
        /// Converts a IDictionary / IList object or a simple type (string, int, etc.) into a JSON string
        /// </summary>
        /// <param name="json">A Dictionary&lt;string, object&gt; / List&lt;object&gt;</param>
        /// <returns>A JSON encoded string, or null if object 'json' is not serializable</returns>
        public static string Serialize(object obj)
        {
            return Serializer.Serialize(obj);
        }

        sealed class Serializer
        {
            StringBuilder builder;

            Serializer()
            {
                builder = new StringBuilder();
            }

            public static string Serialize(object obj)
            {
                var instance = new Serializer();

                instance.SerializeValue(obj);

                return instance.builder.ToString();
            }

            void SerializeValue(object value)
            {
                IList asList;
                IDictionary asDict;
                string asStr;

                if (value == null)
                {
                    builder.Append("null");
                }
                else if ((asStr = value as string) != null)
                {
                    SerializeString(asStr);
                }
                else if (value is bool)
                {
                    builder.Append((bool) value ? "true" : "false");
                }
                else if ((asList = value as IList) != null)
                {
                    SerializeArray(asList);
                }
                else if ((asDict = value as IDictionary) != null)
                {
                    SerializeObject(asDict);
                }
                else if (value is char)
                {
                    SerializeString(new string((char) value, 1));
                }
                else
                {
                    SerializeOther(value);
                }
            }

            void SerializeObject(IDictionary obj)
            {
                bool first = true;

                builder.Append('{');

                foreach (object e in obj.Keys)
                {
                    if (!first)
                    {
                        builder.Append(',');
                    }

                    SerializeString(e.ToString());
                    builder.Append(':');

                    SerializeValue(obj[e]);

                    first = false;
                }

                builder.Append('}');
            }

            void SerializeArray(IList anArray)
            {
                builder.Append('[');

                bool first = true;

                for (int i = 0; i < anArray.Count; i++)
                {
                    object obj = anArray[i];
                    if (!first)
                    {
                        builder.Append(',');
                    }

                    SerializeValue(obj);

                    first = false;
                }

                builder.Append(']');
            }

            void SerializeString(string str)
            {
                builder.Append('\"');

                char[] charArray = str.ToCharArray();
                for (int i = 0; i < charArray.Length; i++)
                {
                    char c = charArray[i];
                    switch (c)
                    {
                        case '"':
                            builder.Append("\\\"");
                            break;
                        case '\\':
                            builder.Append("\\\\");
                            break;
                        case '\b':
                            builder.Append("\\b");
                            break;
                        case '\f':
                            builder.Append("\\f");
                            break;
                        case '\n':
                            builder.Append("\\n");
                            break;
                        case '\r':
                            builder.Append("\\r");
                            break;
                        case '\t':
                            builder.Append("\\t");
                            break;
                        default:
                            int codepoint = Convert.ToInt32(c);
                            if ((codepoint >= 32) && (codepoint <= 126))
                            {
                                builder.Append(c);
                            }
                            else
                            {
                                builder.Append("\\u");
                                builder.Append(codepoint.ToString("x4"));
                            }

                            break;
                    }
                }

                builder.Append('\"');
            }

            void SerializeOther(object value)
            {
                // NOTE: decimals lose precision during serialization.
                // They always have, I'm just letting you know.
                // Previously floats and doubles lost precision too.
                if (value is float)
                {
                    builder.Append(((float) value).ToString("R", System.Globalization.CultureInfo.InvariantCulture));
                }
                else if (value is int
                         || value is uint
                         || value is long
                         || value is sbyte
                         || value is byte
                         || value is short
                         || value is ushort
                         || value is ulong)
                {
                    builder.Append(value);
                }
                else if (value is double
                         || value is decimal)
                {
                    builder.Append(Convert.ToDouble(value)
                        .ToString("R", System.Globalization.CultureInfo.InvariantCulture));
                }
                else
                {
                    SerializeString(value.ToString());
                }
            }
        }
    }

    public class MiniJSON
    {
        private const int TOKEN_NONE = 0;
        private const int TOKEN_CURLY_OPEN = 1;
        private const int TOKEN_CURLY_CLOSE = 2;
        private const int TOKEN_SQUARED_OPEN = 3;
        private const int TOKEN_SQUARED_CLOSE = 4;
        private const int TOKEN_COLON = 5;
        private const int TOKEN_COMMA = 6;
        private const int TOKEN_STRING = 7;
        private const int TOKEN_NUMBER = 8;
        private const int TOKEN_TRUE = 9;
        private const int TOKEN_FALSE = 10;

        private const int TOKEN_NULL = 11;

        //added token for infinity
        private const int TOKEN_INFINITY = 12;
        private const int BUILDER_CAPACITY = 2000;

        /// <summary>
        /// On decoding, this value holds the position at which the parse failed (-1 = no error).
        /// </summary>
        protected static int lastErrorIndex = -1;

        protected static string lastDecode = "";


        /// <summary>
        /// Parses the string json into a value
        /// </summary>
        /// <param name="json">A JSON string.</param>
        /// <returns>An ArrayList, a Hashtable, a double, a string, null, true, or false</returns>
        public static object jsonDecode(string json)
        {
            // save the string for debug information
            MiniJSON.lastDecode = json;

            if (json != null)
            {
                char[] charArray = json.ToCharArray();
                int index = 0;
                bool success = true;
                object value = MiniJSON.parseValue(charArray, ref index, ref success);

                if (success)
                    MiniJSON.lastErrorIndex = -1;
                else
                    MiniJSON.lastErrorIndex = index;

                return value;
            }
            else
            {
                return null;
            }
        }


        /// <summary>
        /// Converts a Hashtable / ArrayList / Dictionary(string,string) object into a JSON string
        /// </summary>
        /// <param name="json">A Hashtable / ArrayList</param>
        /// <returns>A JSON encoded string, or null if object 'json' is not serializable</returns>
        public static string jsonEncode(object json)
        {
            indentLevel = 0;
            var builder = new StringBuilder(BUILDER_CAPACITY);
            var success = MiniJSON.serializeValue(json, builder);

            return (success ? builder.ToString() : null);
        }


        /// <summary>
        /// On decoding, this function returns the position at which the parse failed (-1 = no error).
        /// </summary>
        /// <returns></returns>
        public static bool lastDecodeSuccessful()
        {
            return (MiniJSON.lastErrorIndex == -1);
        }


        /// <summary>
        /// On decoding, this function returns the position at which the parse failed (-1 = no error).
        /// </summary>
        /// <returns></returns>
        public static int getLastErrorIndex()
        {
            return MiniJSON.lastErrorIndex;
        }


        /// <summary>
        /// If a decoding error occurred, this function returns a piece of the JSON string 
        /// at which the error took place. To ease debugging.
        /// </summary>
        /// <returns></returns>
        public static string getLastErrorSnippet()
        {
            if (MiniJSON.lastErrorIndex == -1)
            {
                return "";
            }
            else
            {
                int startIndex = MiniJSON.lastErrorIndex - 5;
                int endIndex = MiniJSON.lastErrorIndex + 15;
                if (startIndex < 0)
                    startIndex = 0;

                if (endIndex >= MiniJSON.lastDecode.Length)
                    endIndex = MiniJSON.lastDecode.Length - 1;

                return MiniJSON.lastDecode.Substring(startIndex, endIndex - startIndex + 1);
            }
        }


        #region Parsing

        protected static Hashtable parseObject(char[] json, ref int index)
        {
            Hashtable table = new Hashtable();
            int token;

            // {
            nextToken(json, ref index);

            bool done = false;
            while (!done)
            {
                token = lookAhead(json, index);
                if (token == MiniJSON.TOKEN_NONE)
                {
                    return null;
                }
                else if (token == MiniJSON.TOKEN_COMMA)
                {
                    nextToken(json, ref index);
                }
                else if (token == MiniJSON.TOKEN_CURLY_CLOSE)
                {
                    nextToken(json, ref index);
                    return table;
                }
                else
                {
                    // name
                    string name = parseString(json, ref index);
                    if (name == null)
                    {
                        return null;
                    }

                    // :
                    token = nextToken(json, ref index);
                    if (token != MiniJSON.TOKEN_COLON)
                        return null;

                    // value
                    bool success = true;
                    object value = parseValue(json, ref index, ref success);
                    if (!success)
                        return null;

                    table[name] = value;
                }
            }

            return table;
        }


        protected static ArrayList parseArray(char[] json, ref int index)
        {
            ArrayList array = new ArrayList();

            // [
            nextToken(json, ref index);

            bool done = false;
            while (!done)
            {
                int token = lookAhead(json, index);
                if (token == MiniJSON.TOKEN_NONE)
                {
                    return null;
                }
                else if (token == MiniJSON.TOKEN_COMMA)
                {
                    nextToken(json, ref index);
                }
                else if (token == MiniJSON.TOKEN_SQUARED_CLOSE)
                {
                    nextToken(json, ref index);
                    break;
                }
                else
                {
                    bool success = true;
                    object value = parseValue(json, ref index, ref success);
                    if (!success)
                        return null;

                    array.Add(value);
                }
            }

            return array;
        }


        protected static object parseValue(char[] json, ref int index, ref bool success)
        {
            switch (lookAhead(json, index))
            {
                case MiniJSON.TOKEN_STRING:
                    return parseString(json, ref index);
                case MiniJSON.TOKEN_NUMBER:
                    return parseNumber(json, ref index);
                case MiniJSON.TOKEN_CURLY_OPEN:
                    return parseObject(json, ref index);
                case MiniJSON.TOKEN_SQUARED_OPEN:
                    return parseArray(json, ref index);
                case MiniJSON.TOKEN_TRUE:
                    nextToken(json, ref index);
                    return Boolean.Parse("TRUE");
                case MiniJSON.TOKEN_FALSE:
                    nextToken(json, ref index);
                    return Boolean.Parse("FALSE");
                case MiniJSON.TOKEN_NULL:
                    nextToken(json, ref index);
                    return null;
                case MiniJSON.TOKEN_INFINITY:
                    nextToken(json, ref index);
                    return float.PositiveInfinity;
                case MiniJSON.TOKEN_NONE:
                    break;
            }

            success = false;
            return null;
        }


        protected static string parseString(char[] json, ref int index)
        {
            string s = "";
            char c;

            eatWhitespace(json, ref index);

            // "
            c = json[index++];

            bool complete = false;
            while (!complete)
            {
                if (index == json.Length)
                    break;

                c = json[index++];
                if (c == '"')
                {
                    complete = true;
                    break;
                }
                else if (c == '\\')
                {
                    if (index == json.Length)
                        break;

                    c = json[index++];
                    if (c == '"')
                    {
                        s += '"';
                    }
                    else if (c == '\\')
                    {
                        s += '\\';
                    }
                    else if (c == '/')
                    {
                        s += '/';
                    }
                    else if (c == 'b')
                    {
                        s += '\b';
                    }
                    else if (c == 'f')
                    {
                        s += '\f';
                    }
                    else if (c == 'n')
                    {
                        s += '\n';
                    }
                    else if (c == 'r')
                    {
                        s += '\r';
                    }
                    else if (c == 't')
                    {
                        s += '\t';
                    }
                    else if (c == 'u')
                    {
                        int remainingLength = json.Length - index;
                        if (remainingLength >= 4)
                        {
                            char[] unicodeCharArray = new char[4];
                            Array.Copy(json, index, unicodeCharArray, 0, 4);

                            // Drop in the HTML markup for the unicode character
                            s += "&#x" + new string(unicodeCharArray) + ";";

                            /*
    uint codePoint = UInt32.Parse(new string(unicodeCharArray), NumberStyles.HexNumber);
    // convert the integer codepoint to a unicode char and add to string
    s += Char.ConvertFromUtf32((int)codePoint);
    */

                            // skip 4 chars
                            index += 4;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                else
                {
                    s += c;
                }
            }

            if (!complete)
                return null;

            return s;
        }


        protected static float parseNumber(char[] json, ref int index)
        {
            eatWhitespace(json, ref index);

            int lastIndex = getLastIndexOfNumber(json, index);
            int charLength = (lastIndex - index) + 1;
            char[] numberCharArray = new char[charLength];

            Array.Copy(json, index, numberCharArray, 0, charLength);
            index = lastIndex + 1;
            return float.Parse(new string(numberCharArray)); // , CultureInfo.InvariantCulture);
        }


        protected static int getLastIndexOfNumber(char[] json, int index)
        {
            int lastIndex;
            for (lastIndex = index; lastIndex < json.Length; lastIndex++)
                if ("0123456789+-.eE".IndexOf(json[lastIndex]) == -1)
                {
                    break;
                }

            return lastIndex - 1;
        }


        protected static void eatWhitespace(char[] json, ref int index)
        {
            for (; index < json.Length; index++)
                if (" \t\n\r".IndexOf(json[index]) == -1)
                {
                    break;
                }
        }


        protected static int lookAhead(char[] json, int index)
        {
            int saveIndex = index;
            return nextToken(json, ref saveIndex);
        }


        protected static int nextToken(char[] json, ref int index)
        {
            eatWhitespace(json, ref index);

            if (index == json.Length)
            {
                return MiniJSON.TOKEN_NONE;
            }

            char c = json[index];
            index++;
            switch (c)
            {
                case '{':
                    return MiniJSON.TOKEN_CURLY_OPEN;
                case '}':
                    return MiniJSON.TOKEN_CURLY_CLOSE;
                case '[':
                    return MiniJSON.TOKEN_SQUARED_OPEN;
                case ']':
                    return MiniJSON.TOKEN_SQUARED_CLOSE;
                case ',':
                    return MiniJSON.TOKEN_COMMA;
                case '"':
                    return MiniJSON.TOKEN_STRING;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                case '-':
                    return MiniJSON.TOKEN_NUMBER;
                case ':':
                    return MiniJSON.TOKEN_COLON;
            }

            index--;

            int remainingLength = json.Length - index;

            // Infinity
            if (remainingLength >= 8)
            {
                if (json[index] == 'I' &&
                    json[index + 1] == 'n' &&
                    json[index + 2] == 'f' &&
                    json[index + 3] == 'i' &&
                    json[index + 4] == 'n' &&
                    json[index + 5] == 'i' &&
                    json[index + 6] == 't' &&
                    json[index + 7] == 'y')
                {
                    index += 8;
                    return MiniJSON.TOKEN_INFINITY;
                }
            }

            // false
            if (remainingLength >= 5)
            {
                if (json[index] == 'f' &&
                    json[index + 1] == 'a' &&
                    json[index + 2] == 'l' &&
                    json[index + 3] == 's' &&
                    json[index + 4] == 'e')
                {
                    index += 5;
                    return MiniJSON.TOKEN_FALSE;
                }
            }

            // true
            if (remainingLength >= 4)
            {
                if (json[index] == 't' &&
                    json[index + 1] == 'r' &&
                    json[index + 2] == 'u' &&
                    json[index + 3] == 'e')
                {
                    index += 4;
                    return MiniJSON.TOKEN_TRUE;
                }
            }

            // null
            if (remainingLength >= 4)
            {
                if (json[index] == 'n' &&
                    json[index + 1] == 'u' &&
                    json[index + 2] == 'l' &&
                    json[index + 3] == 'l')
                {
                    index += 4;
                    return MiniJSON.TOKEN_NULL;
                }
            }

            return MiniJSON.TOKEN_NONE;
        }

        #endregion


        #region Serialization

        protected static bool serializeObjectOrArray(object objectOrArray, StringBuilder builder)
        {
            if (objectOrArray is Hashtable)
            {
                return serializeObject((Hashtable) objectOrArray, builder);
            }
            else if (objectOrArray is ArrayList)
            {
                return serializeArray((ArrayList) objectOrArray, builder);
            }
            else
            {
                return false;
            }
        }

        protected static int indentLevel = 0;

        protected static bool serializeObject(Hashtable anObject, StringBuilder builder)
        {
            indentLevel++;
            string indentString = "";
            for (int i = 0; i < indentLevel; i++)
                indentString += "\t";

            builder.Append("{\n" + indentString);


            IDictionaryEnumerator e = anObject.GetEnumerator();
            bool first = true;
            while (e.MoveNext())
            {
                string key = e.Key.ToString();
                object value = e.Value;

                if (!first)
                {
                    builder.Append(", \n" + indentString);
                }

                serializeString(key, builder);
                builder.Append(":");
                if (!serializeValue(value, builder))
                {
                    return false;
                }

                first = false;
            }


            indentString = "";
            for (int i = 0; i < indentLevel - 1; i++)
                indentString += "\t";

            builder.Append("\n" + indentString + "}");

            indentLevel--;
            return true;
        }


        protected static bool serializeDictionary(Dictionary<string, string> dict, StringBuilder builder)
        {
            builder.Append("{");

            bool first = true;
            foreach (var kv in dict)
            {
                if (!first)
                    builder.Append(", ");

                serializeString(kv.Key, builder);
                builder.Append(":");
                serializeString(kv.Value, builder);

                first = false;
            }

            builder.Append("}");
            return true;
        }


        protected static bool serializeArray(ArrayList anArray, StringBuilder builder)
        {
            indentLevel++;
            string indentString = "";
            for (int i = 0; i < indentLevel; i++)
                indentString += "\t";

            builder.Append("[\n" + indentString);
//		builder.Append( "[" );


            bool first = true;
            for (int i = 0; i < anArray.Count; i++)
            {
                object value = anArray[i];

                if (!first)
                {
                    builder.Append(", \n" + indentString);
                }

                if (!serializeValue(value, builder))
                {
                    return false;
                }

                first = false;
            }


            indentString = "";
            for (int i = 0; i < indentLevel - 1; i++)
                indentString += "\t";

            builder.Append("\n" + indentString + "]");

            indentLevel--;

            return true;
        }


        protected static bool serializeValue(object value, StringBuilder builder)
        {
            // Type t = value.GetType();
            // Debug.Log("type: " + t.ToString() + " isArray: " + t.IsArray);

            if (value == null)
            {
                builder.Append("null");
            }
            else if (value.GetType().IsArray)
            {
                serializeArray(new ArrayList((ICollection) value), builder);
            }
            else if (value is string)
            {
                serializeString((string) value, builder);
            }
            else if (value is Char)
            {
                serializeString(Convert.ToString((char) value), builder);
            }
            else if (value is Hashtable)
            {
                serializeObject((Hashtable) value, builder);
            }
            else if (value is Dictionary<string, string>)
            {
                serializeDictionary((Dictionary<string, string>) value, builder);
            }
            else if (value is ArrayList)
            {
                serializeArray((ArrayList) value, builder);
            }
            else if ((value is Boolean) && ((Boolean) value == true))
            {
                builder.Append("true");
            }
            else if ((value is Boolean) && ((Boolean) value == false))
            {
                builder.Append("false");
            }
            else if (value.GetType().IsPrimitive)
            {
                serializeNumber(Convert.ToSingle(value), builder);
            }
            else
            {
                return false;
            }

            return true;
        }


        protected static void serializeString(string aString, StringBuilder builder)
        {
            builder.Append("\"");

            char[] charArray = aString.ToCharArray();
            for (int i = 0; i < charArray.Length; i++)
            {
                char c = charArray[i];
                if (c == '"')
                {
                    builder.Append("\\\"");
                }
                else if (c == '\\')
                {
                    builder.Append("\\\\");
                }
                else if (c == '\b')
                {
                    builder.Append("\\b");
                }
                else if (c == '\f')
                {
                    builder.Append("\\f");
                }
                else if (c == '\n')
                {
                    builder.Append("\\n");
                }
                else if (c == '\r')
                {
                    builder.Append("\\r");
                }
                else if (c == '\t')
                {
                    builder.Append("\\t");
                }
                else
                {
                    int codepoint = Convert.ToInt32(c);
                    if ((codepoint >= 32) && (codepoint <= 126))
                    {
                        builder.Append(c);
                    }
                    else
                    {
                        builder.Append("\\u" + Convert.ToString(codepoint, 16).PadLeft(4, '0'));
                    }
                }
            }

            builder.Append("\"");
        }


        protected static void serializeNumber(float number, StringBuilder builder)
        {
            builder.Append(Convert.ToString(number)); // , CultureInfo.InvariantCulture));
        }

        #endregion
    }


    #region Extension methods

    public static class MiniJsonExtensions
    {
        public static string toJson(this Hashtable obj)
        {
            return MiniJSON.jsonEncode(obj);
        }

        public static string toJson(this Dictionary<string, string> obj)
        {
            return MiniJSON.jsonEncode(obj);
        }


        public static ArrayList arrayListFromJson(this string json)
        {
            return MiniJSON.jsonDecode(json) as ArrayList;
        }


        public static Hashtable hashtableFromJson(this string json)
        {
            return MiniJSON.jsonDecode(json) as Hashtable;
        }
    }

    #endregion
}