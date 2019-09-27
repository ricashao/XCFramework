using System.IO;

public static class os
{
    public static class path
    {
        //拼接路径
        public static string join(string path1, string path2)
        {
            if (null == path1 || path1.Length == 0)
            {
                return path2;
            }

            if (null == path2 || path2.Length == 0)
            {
                return path1;
            }

            if (Path.IsPathRooted(path2))
            {
                return path2;
            }

            char c = path1[path1.Length - 1];
            if (c != Path.DirectorySeparatorChar && c != Path.AltDirectorySeparatorChar &&
                c != Path.VolumeSeparatorChar)
            {
                return path1 + '/' + path2;
            }

            return path1 + path2;
        }

        public static string join(string path1, string path2, string path3)
        {
            return path.join(path1, path.join(path2, path3));
        }

        public static long getsize(string filename)
        {
            try
            {
                var fileInfo = new FileInfo(filename);
                var size = fileInfo.Length;
                return size;
            }
            catch (System.Exception)
            {
                return 0;
            }
        }

        public static string normpath(string path)
        {
            if (!string.IsNullOrEmpty(path))
            {
                return path.Replace('\\', '/');
            }

            return path;
        }
    }

    public static void startfile(string filename, string arguments = null, bool shell = false)
    {
        var process = new System.Diagnostics.Process();
        var si = process.StartInfo;
        si.FileName = filename;
        si.Arguments = arguments;
        si.UseShellExecute = shell;
        process.Start();
    }

    /// <summary>
    /// 创建目录
    /// </summary>
    /// <param name="path"></param>
    public static void mkdir(string path)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
    }

    /// <summary>
    /// 遍历文件夹下的特定文件
    /// </summary>
    /// <param name="path"></param>
    /// <param name="searchPattern"></param>
    /// <returns></returns>
    public static string[] walk(string path, string searchPattern)
    {
        if (Directory.Exists(path))
        {
            var paths = Directory.GetFiles(path, searchPattern, SearchOption.AllDirectories);
            return paths;
        }

        return _emptyPaths;
    }

    public const string linesep = "\n";
    private static readonly string[] _emptyPaths = new string[0];
}