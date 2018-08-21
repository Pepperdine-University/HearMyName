using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetCasClient;
using DotNetCasClient.Security;
using HearMyName.Helpers;


namespace HearMyName
{
    public partial class Default : System.Web.UI.Page
    {    
        protected void Page_Load(object sender, EventArgs e)
        {
         
            System.Text.StringBuilder retVal = new System.Text.StringBuilder();

            ICasPrincipal p = HttpContext.Current.User as ICasPrincipal;
            if (p != null)
            {
                foreach (System.Collections.Generic.KeyValuePair<string, IList<string>> grouping in p.Assertion.Attributes)
                {
                    retVal.Append(@"<br/>" + grouping.Key + ": ");
                    foreach (string attrValue in p.Assertion.Attributes[grouping.Key])
                    {
                        retVal.Append(attrValue);
                    }
                }
            }

            Response.Write(retVal.ToString());

            int cwid =  CasAuthentication.CurrentPrincipal == null ? 100 :
                                      Int32.Parse(CasAuthentication.CurrentPrincipal.Assertion.Attributes["employeeID"][0]);    
            if (HearMyNameHelper.isUserAnAdmin(cwid))
            {

                Response.Redirect("~/Admin/Default.aspx");
            }
            else
            {
                Response.Redirect("~/Profile.aspx");
            }


        }


    }
}