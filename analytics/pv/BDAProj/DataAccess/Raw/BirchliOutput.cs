using DataAccess.Api;
using DataAccess.Slc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace DataAccess.Raw
{
    public class BirchliOutput
    {
        private PvDataConfig config;

        public BirchliOutput(PvDataConfig config)
        {
            this.config = config ?? throw new ArgumentNullException(nameof(config));
        }

        public void WriteOutput(List<PvLine> inputLines)
        {
            using (StreamWriter sw = File.CreateText(Path.Combine(config.TargetFolder, config.TargetFileName)))
            {
                sw.WriteLine($"timestampText;timestamp;power1;power2");

                foreach (PvLine inputLine in inputLines)
                {
                    sw.WriteLine($"{inputLine.Timestamp};{inputLine.TimestampUnix};{inputLine.Power1};{inputLine.Power2}");
                }
            }
        }
    }
}
