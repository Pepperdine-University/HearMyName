using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NLog;

namespace HearMyName.Helpers
{

    /// <summary>
    ///     Helper functions for working with logs
    /// </summary>
    public static class LogHelper
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();
        /// <summary>
        ///  This helps enable logging all over the code, instead of just where ESTContext exists. 
        /// </summary>
        public static void LogMessage(string Message)
        {
            try
            { 
            logger.Info(Message);
            }
            catch(Exception ex)
            {
                string exception = ex.ToString();
            }
        }

        public static void LogError(string Message)
        {
            logger.Error(Message);
        }
    }
}
