using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Ops
{
    public static class Archiver
    {
        public static void ArchiveSolution(bool openFolder)
        {
            string archiveFolder = @"D:\bkp";
            string solutionFolder = null;
            string solutionName = null;

            string searchFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            while (true)
            {
                solutionName = Directory.GetFiles(searchFolder, "*.sln").FirstOrDefault();
                if (solutionName != null)
                    break;

                searchFolder = Directory.GetParent(searchFolder)?.ToString();
                if (searchFolder == null)
                    break;
            };
            solutionFolder = Path.GetDirectoryName(solutionName);
            solutionName = Path.GetFileNameWithoutExtension(solutionName);

            File.Copy(solutionFolder, Path.Combine(archiveFolder, solutionName));

            string timestamp = DateTimeOffset.Now.ToString("yyyy-MM-dd HH-mm-ss");
            string archiveFileName = $"{timestamp} {solutionName}.zip";

            ZipFile.CreateFromDirectory(solutionFolder, Path.Combine(archiveFolder, archiveFileName));

            if (openFolder)
                Process.Start(archiveFolder);
        }
    }
}
