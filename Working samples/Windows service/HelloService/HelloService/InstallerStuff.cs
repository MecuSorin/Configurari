using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace HelloService
{
	[RunInstaller(true)]
	public sealed class ProjectInstaller : Installer
	{
		public ProjectInstaller()
		{
			_serviceProcessInstaller = new ServiceProcessInstaller();
			_serviceInstaller = new ServiceInstaller();

			_serviceInstaller.Description = "Sample service that outputs a message to a file";
			_serviceInstaller.DisplayName = "Hello Service";
			_serviceInstaller.ServiceName = HelloService.DefinedServiceName;
			_serviceInstaller.StartType = ServiceStartMode.Automatic;

			_serviceProcessInstaller.Username = null;
			_serviceProcessInstaller.Password = null;
			_serviceProcessInstaller.Account = ServiceAccount.NetworkService;

			Installers.Add(_serviceProcessInstaller);
            Installers.Add(_serviceInstaller);
		}

		private ServiceProcessInstaller _serviceProcessInstaller;
		private ServiceInstaller _serviceInstaller;

		protected override void Dispose(bool disposing)
		{
			base.Dispose(disposing);
			if (null != _serviceInstaller)
				_serviceInstaller.Dispose();
			if (null != _serviceProcessInstaller)
				_serviceProcessInstaller.Dispose();
		}
	}
}
