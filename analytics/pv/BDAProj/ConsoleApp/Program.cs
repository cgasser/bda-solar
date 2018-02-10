using DataAccess.Api;
using DataAccess.Raw;
using Ops;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                PvDataConfig config = new PvDataConfig
                {
                    SourceFolder = @"D:\SBEAM",
                    SourceFileNamePattern = @"^(\d){2}-(\d){2}-(\d){2}.csv$",
                    TargetFolder = @"C:\RProjects\bda-solar\analytics\pv\HSLU_BDA_Solar\data",
                    TargetFileName = @"birchli.csv"
                };

                BirchliData birchliData = new BirchliData(config);

                while (true)
                {
                    Console.WriteLine("list - list files");
                    Console.WriteLine("print - print all data");
                    Console.WriteLine("write - write output file");
                    Console.Write("Your selection: ");
                    string input = Console.ReadLine();
                    Console.WriteLine();

                    switch (input)
                    {
                        case "":
                            return;
                        case "backup":
                            Archiver.ArchiveSolution(true);
                            break;
                        case "list":
                            int idx = 0;
                            foreach (string fileName in birchliData.GetFileNames())
                            {
                                Console.WriteLine($"{idx++.ToString().PadLeft(4)} - {fileName}");
                            }
                            break;
                        case "print":
                            Console.ForegroundColor = ConsoleColor.Yellow;
                            Stopwatch stopwatch = Stopwatch.StartNew();
                            foreach (var diag in birchliData.ReadAllFiles())
                            {
                                Console.WriteLine(diag.Print("yyyy-MM-dd HH:mm:ss.ffff"));
                            }
                            stopwatch.Stop();
                            Console.ForegroundColor = ConsoleColor.Magenta;
                            Console.WriteLine(stopwatch.Elapsed);
                            Console.ForegroundColor = ConsoleColor.Cyan;
                            Console.WriteLine(birchliData.GetStats());
                            Console.ResetColor();
                            break;
                        case "write":
                            var inputData = birchliData.ReadAllFiles().ToList();
                            BirchliOutput birchliOutput = new BirchliOutput(config);
                            birchliOutput.WriteOutput(inputData);
                            break;
                    }
                    Console.WriteLine();
                }
            }
            catch (Exception exc)
            {
                Console.BackgroundColor = ConsoleColor.DarkRed;
                Console.ForegroundColor = ConsoleColor.White;
                Console.WriteLine(exc);
                Console.ResetColor();
                Console.ReadLine();
            }
            finally
            {
            }
        }
    }
}
