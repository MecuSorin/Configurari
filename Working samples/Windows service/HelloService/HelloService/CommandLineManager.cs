using System;
using System.Collections;
using System.Configuration.Install;
using System.Reflection;
using System.ServiceProcess;
using System.Text.RegularExpressions;

namespace HelloService
{
	public static class Program
	{
		static void Main(params string[] args)
		{
			try
			{
				Action commandToExecute = null;
				CommandLineManager commandLineManager = new CommandLineManager(args, typeof(CommandLineManager).Assembly);
				commandToExecute = commandLineManager.StartTheService;
				if (null != args && args.Length == 1)
				{
					Regex regex = new Regex(@"\W*(?i)(\w).*");
					string arg = regex.Match(args[0]).Groups[1].Value.ToLower();
					switch (arg)
					{
						case "a": commandToExecute = commandLineManager.ActivateTheService; break;
						case "i": commandToExecute = commandLineManager.InstallTheService; break;
						case "u": commandToExecute = commandLineManager.UninstallTheService; break;
						default:
							commandToExecute = commandLineManager.StartTheService; 
							break;
					}
				}
				if (null != commandToExecute)
					commandToExecute();
			}
			catch (Exception exc)
			{
				CommandLineManager.InternalTrace("failed " + exc.ToString());
			}
		}
	}

	public class CommandLineManager
	{
		internal CommandLineManager(string[] args, Assembly installersAssembly)
		{
			Args = args;
			InstallersAssembly = installersAssembly;
		}

		public string[] Args { get; private set; }
		public Assembly InstallersAssembly { get; private set; }

		public void InstallTheService()
		{
			try
			{
				IDictionary state = new Hashtable();
				using (AssemblyInstaller installer = new AssemblyInstaller(InstallersAssembly, Args))
				{
					installer.UseNewContext = true;
					try
					{
						installer.Install(state);
						installer.Commit(state);
						InternalTrace("Installed the service");
					}
					catch (Exception installException)
					{
						try
						{
							installer.Rollback(state);
							InternalTrace("Rolledback the service installation because:" + installException.ToString());
						}
						catch { }
						throw;
					}
				}
			}
			catch (Exception exception)
			{
				InternalTrace("Failed to install the service " + exception.ToString());
			}
		}

		public void UninstallTheService()
		{
			try
			{
				IDictionary state = new Hashtable();
				using (AssemblyInstaller installer = new AssemblyInstaller(InstallersAssembly, Args))
				{
					installer.UseNewContext = true;
					try
					{
						installer.Uninstall(state);
						InternalTrace("Uninstalled the service");
					}
					catch (Exception uninstallException)
					{
						try
						{
							installer.Rollback(state);
							InternalTrace("Rolledback the service uninstallation because:" + uninstallException.ToString());
						}
						catch { }
						throw;
					}
				}
			}
			catch (Exception exception)
			{
				InternalTrace("Failed to uninstall the service " + exception.ToString());
			}
		}

		public void StartTheService()
		{
			try
			{
				ServiceBase[] ServicesToRun = new ServiceBase[] { new HelloService() };
				ServiceBase.Run(ServicesToRun);
			}
			catch (Exception exception)
			{
				InternalTrace("Failed to start the service" + exception.ToString());
			}
		}

		public void ActivateTheService()
		{
			try
			{
				ServiceController controller = new ServiceController(HelloService.DefinedServiceName);
				controller.Start();
			}
			catch (Exception exception)
			{
				InternalTrace("Failed to activate the service" + exception.ToString());
			}
		}

		public static void InternalTrace(string message)
		{
			try
			{
				const string TmpLogFile = @"d:\DeSters\tmp_errors.log"  // on purpose to allow entering a proper path (the installer should update a config file with the full path to the file - don't forget the service current path is not the one you are expecting)
				using (var stream = System.IO.File.AppendText(TmpLogFile))
				{
					stream.WriteLine(message);
				}
			}
			catch { }
		}
	}
}
