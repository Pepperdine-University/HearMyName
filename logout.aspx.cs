using System;
using System.Web;
using System.Web.Security;

namespace HearMyName
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string casBaseUrl = DotNetCasClient.CasAuthentication.CasServerUrlPrefix;
            if (! string.IsNullOrEmpty(User.Identity.Name))
            {
                string isNSO = string.IsNullOrEmpty(Request.QueryString["nso"]) || string.Equals("true", Request.QueryString["nso"]) ? "true" : "false";
                DotNetCasClient.CasAuthentication.ClearAuthCookie();
                FormsAuthentication.SignOut();
                Response.Cache.SetExpires(DateTime.Now);        

 

                if (bool.Parse(isNSO))
                { 
                    UriBuilder redirectUri = new UriBuilder(Request.Url)
                    {
                        Query ="",
                        Path = $"{Request.ApplicationPath}/Profile.aspx?nso=true"
                    };
                }
                else
                {
                    UriBuilder redirectUri = new UriBuilder(Request.Url)
                    {
                        Query = "",
                        Path = $"{Request.ApplicationPath}"
                    };
                }
                    



            }
        }
    }
}