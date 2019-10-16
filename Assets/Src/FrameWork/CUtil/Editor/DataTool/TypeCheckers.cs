using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class TypeCheckers
{
    public static Dictionary<string, TypeChecker> checkers = new Dictionary<string, TypeChecker>()
    {
        {"number", new NumberChekcer()},
        {"string", new StringChecker()},
    };
}


class StringChecker : TypeChecker
{
    public override object Check(string value)
    {
        return value;
    }
}

class NumberChekcer : TypeChecker
{
    public override object Check(string value)
    {
        value = value.Trim();
        if (string.IsNullOrEmpty(value))
            return 0;
        Regex regex = new Regex("^-?[0-9.]+$");
        if (value.Split('.').Length <= 2 && (regex.IsMatch(value)))
        {
            return Double.Parse(value);
        }
        else
        {
            throw new ValueTypeException("number", value);
        }
    }
}

public class ValueTypeException : ApplicationException
{
    private string error;

    public ValueTypeException(string type, string msg) : base(msg)
    {
        this.error = string.Format("数据和类型不匹配，当前类型：{0}，数据：{1}", type, msg);
    }

    public string GetError()
    {
        return error;
    }
}