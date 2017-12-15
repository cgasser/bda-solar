using DataAccess.Api;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DataAccess.Raw
{
    internal class PVDataFolder
    {
        public string FileNamePattern => config.SourceFileNamePattern;

        private PvDataConfig config;

        public PVDataFolder(PvDataConfig config)
        {
            this.config = config ?? throw new ArgumentNullException(nameof(config));
        }

        public bool IsInitialized => !string.IsNullOrWhiteSpace(config.SourceFolder) && !string.IsNullOrWhiteSpace(config.SourceFileNamePattern);

        internal IEnumerable<string> GetFileNames()
        {
            if (!IsInitialized)
                throw new InvalidOperationException("!IsInitialized");

            return Directory.GetFiles(config.SourceFolder).Select(filenameWithPath => Path.GetFileName(filenameWithPath)).Where(filename => Regex.IsMatch(filename, FileNamePattern, RegexOptions.IgnoreCase)).OrderBy(fileName => fileName);
        }
    }
}
