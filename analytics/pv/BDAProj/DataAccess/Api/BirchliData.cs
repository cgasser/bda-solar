using DataAccess.Raw;
using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using DataAccess.Slc;

namespace DataAccess.Api
{
    public class BirchliData
    {
        private PvDataConfig config;

        private List<PvLine> allLines;
        private IEnumerable<PvLine> AllLines => allLines ?? ReadAllFiles();

        public BirchliData(PvDataConfig config)
        {
            this.config = config ?? throw new ArgumentNullException(nameof(config));
        }

        public IEnumerable<string> GetFileNames()
        {
            PVDataFolder folder = new PVDataFolder(config);

            return folder.GetFileNames();
        }

        public IEnumerable<PvLine> ReadFile(int fileIdx)
        {
            string file = GetFileNames().ElementAtOrDefault(fileIdx) ?? throw new ArgumentException(nameof(fileIdx));

            var diagFile = new BirchliFile { FileName = file, Folder = config.SourceFolder };

            diagFile.Read();
            diagFile.Parse();

            return diagFile.Lines;
        }

        public IEnumerable<PvLine> ReadAllFiles()
        {
            allLines = GetFileNames().SelectMany((file, idx) => ReadFile(idx)).ToList();

            return allLines;
        }

        public string GetStats()
        {
            decimal Power1Min = AllLines.Select(line => line.Power1).Min();
            decimal Power1Max = AllLines.Select(line => line.Power1).Max();
            decimal Power2Min = AllLines.Select(line => line.Power2).Min();
            decimal Power2Max = AllLines.Select(line => line.Power2).Max();

            return $"Power1: [{Power1Min:N3}..{Power1Max:N3}] / Power2: [{Power2Min:N3}..{Power2Max:N3}]";
        }
    }
}
