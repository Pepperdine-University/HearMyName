using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace HearMyName.Helpers
{
    public class HearMyNameHelper
    {
        public static Boolean isUserAnAdmin(int CWID)
        {
            return getUserRole(CWID).Equals("Admin");              
        }

        public static string getUserRole(int CWID)
        {
            int cwid = DotNetCasClient.CasAuthentication.CurrentPrincipal == null ? 100 :
                                 Int32.Parse(DotNetCasClient.CasAuthentication.CurrentPrincipal.Assertion.Attributes["employeeID"][0]);
            string userRole;

            using (var db = new HearMyNameEntities())
            {
                System.Data.Entity.Core.Objects.ObjectParameter cwidParam = new System.Data.Entity.Core.Objects.ObjectParameter("userCWID", cwid.ToString());
                System.Data.Entity.Core.Objects.ObjectParameter roleParam = new System.Data.Entity.Core.Objects.ObjectParameter("userRole", typeof(string));

                var test = db.GetUserRole(cwid, roleParam).First().ToString();
                userRole = roleParam.Value.ToString();
            }

            if (userRole != null)
            {
                return userRole;
            }
            else
            {
                return $"NO_ROLE_FOUND_FOR_USER_{CWID}";
            }

        }
    }
}