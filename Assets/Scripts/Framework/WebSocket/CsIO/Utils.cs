using System;
using System.Text;

namespace Networks
{
    public static class Utils
    {
        private static readonly DateTime DateStart = new DateTime(1970, 1, 1);

        public static long CurrentTimeMillis()
        {
            return (long) (DateTime.UtcNow - DateStart).TotalMilliseconds;
        }
        
        public static int Roundup(int src, int initial)
        {
            var dst = initial;
            while (dst < src)
                dst <<= 1;
            return dst;
        }

        public static string BytesToHexString(byte[] bytes)
        {
            var sb = new StringBuilder();
            foreach (var b in bytes)
            {
                sb.AppendFormat("{0:x2}", b);
            }
            return sb.ToString();
        }

        private const string HexDigits = "0123456789abcdef";
        public static byte[] HexStringToBytes(string str)
        {
            var bytes = new byte[str.Length >> 1];
            for (var i = 0; i < str.Length; i += 2)
            {
                int highDigit = HexDigits.IndexOf(Char.ToLowerInvariant(str[i]));
                int lowDigit = HexDigits.IndexOf(Char.ToLowerInvariant(str[i + 1]));
                if (highDigit == -1 || lowDigit == -1)
                {
                    throw new ArgumentException("The string contains an invalid digit.");
                }
                bytes[i >> 1] = (byte)((highDigit << 4) | lowDigit);
            }
            return bytes;
        }
    }
}
