using System.ServiceProcess;

namespace HelloService
{
	public partial class HelloService : ServiceBase
	{
		public HelloService()
		{
			InitializeComponent();
		}

		public const string DefinedServiceName = "HelloService";

		protected override void OnStart(string[] args)
		{
			// TODO: Add code here to start your service.
			CommandLineManager.InternalTrace("Started");
		}

		protected override void OnStop()
		{
			// TODO: Add code here to perform any tear-down necessary to stop your service.
			CommandLineManager.InternalTrace("Stopped");
		}

	}
}
