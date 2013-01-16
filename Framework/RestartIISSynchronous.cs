using System.Diagnostics;

namespace MMS.Framework.Commands
{
	internal class CommandIISRestart : CommandBase
	{
		public override void Execute()
		{
			base.Execute();
			System.Diagnostics.Process process = new System.Diagnostics.Process();
			//process.StartInfo.FileName = @"C:\WINDOWS\system32\iisreset.exe";
			process.StartInfo.FileName = "cmd";
			process.StartInfo.Arguments = "/C iisreset /restart";
			process.StartInfo.UseShellExecute = false;
			process.StartInfo.CreateNoWindow = true;
			process.StartInfo.RedirectStandardError = true;
			process.StartInfo.RedirectStandardOutput = true;
			process.Start();
			process.WaitForExit();
			
			this.Notify("Done the IIS restart");
		}
	}
}