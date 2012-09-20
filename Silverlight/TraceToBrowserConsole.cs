using System;
using System.Threading;
using System.Windows;
using System.Windows.Browser;
using System.Windows.Threading;

namespace SASGSilverlightMapControl
{
	public class Log
	{
		public static void Write(object message, params object[] values)
		{
			HtmlWindow window = HtmlPage.Window;
			var isConsoleAvailable = (bool)window.Eval("typeof(console) != 'undefined' && typeof(console.log) != 'undefined'");
			if (isConsoleAvailable)
			{
				var createLogFunction = (bool)window.Eval("typeof(sllog) == 'undefined'");
				if (createLogFunction)
				{
					// Load the logging function into global scope:
					string logFunction = "function sllog(msg) { console.log(msg); }";
					string code = string.Format(@"if(window.execScript) {{ window.execScript('{0}'); }} else {{ eval.call(null, '{0}'); }}", logFunction);
					window.Eval(code);
				}

				// Prepare the message
				DateTime dateTime = DateTime.Now;
				string output = string.Format("{0} - {1}", dateTime.ToString("u"), string.Format(message.ToString(), values));

				// Invoke the logging function:
				var logger = window.Eval("sllog") as ScriptObject;
				if (logger != null)
				{
					// Workaround: Cannot call InvokeSelf outside of UI thread, without dispatcher
					Dispatcher d = Deployment.Current.Dispatcher;
					if (!d.CheckAccess())
					{
						d.BeginInvoke((ThreadStart)(() => logger.InvokeSelf(output)));
					}
					else
					{
						logger.InvokeSelf(output);
					}
				}
			}
		}
	}
}
