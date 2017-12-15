using System;
using System.Collections.Generic;
using System.Text;

namespace DataAccess.Api
{
    public class PvDataConfig
    {
        public string SourceFolder { get; set; }
        public string SourceFileNamePattern { get; set; }
        public string TargetFolder { get; set; }
        public string TargetFileName{ get; set; }
    }
}
