using DotNetCasClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Data.Entity;
using System.Web.Services;

namespace HearMyName
{
    public partial class HearNames : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string cwid = CasAuthentication.CurrentPrincipal == null ? "100" :
                                 CasAuthentication.CurrentPrincipal.Assertion.Attributes["employeeID"][0];  //CWID is the student ID. It is used to identify their recordings as well. 

            if (Helpers.HearMyNameHelper.isUserAnAdmin(Int32.Parse(cwid)))
            {
                liReview.Visible = true;
            }

            if (!IsPostBack)
                loadData(string.Empty);

        }

        private void loadData(string bulkSearch)
        {
            string possibleBulkSearch = string.Empty;
            if (!string.IsNullOrEmpty(Request.QueryString["BulkSearch"]))
            { 
                possibleBulkSearch = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(HttpUtility.UrlDecode(Request.QueryString["BulkSearch"])));
                groupSearchTextBox.InnerText = possibleBulkSearch;
            }

            List<string> bulkSearchQuery = groupSearchTextBox.InnerText.Trim().Split(',').Select(p => p.Trim()).ToList();
            using (var db = new HearMyNameEntities())
            {
                List<LatestRecordingStatus> searchSet;
                if (string.IsNullOrEmpty(possibleBulkSearch) && string.IsNullOrEmpty(bulkSearch))
                    searchSet = db.LatestRecordingStatuses.ToList();
                else
                {
                    searchSet = (from LatestRecordingStatus in db.LatestRecordingStatuses
                                 where bulkSearchQuery.Contains(LatestRecordingStatus.StudentCWID.ToString())
                                 select LatestRecordingStatus).ToList();
                  


                }

                foreach (LatestRecordingStatus r in searchSet)
                {
                    TableRow newRow = new TableRow();

                    TableCell CWIDcell = new TableCell();
                    TableCell systemNameCell = new TableCell();
                    TableCell preferredNameCell = new TableCell();
                    TableCell phoneticCell = new TableCell();
                    TableCell playCell = new TableCell();

                    CWIDcell.Text = r.StudentCWID.ToString();
                    systemNameCell.Text = r.StudentName.Replace("(student)", "");
                    preferredNameCell.Text = r.StudentPreferredName.Replace("(student)", "");
                    phoneticCell.Text = r.Pronounciation;
                    
                    //Audio Play Cell
                    var play = new HtmlGenericControl("audio");
                    play.ID = r.StudentCWID + "Audio";
                    play.ClientIDMode = System.Web.UI.ClientIDMode.Static;
                    play.Attributes.Add("class", "AudioControl");
                    play.Attributes.Add("hidden", "true");
                    play.Attributes.Add("src", $"{ResolveUrl("~/userfiles/converted/")}{r.StudentCWID}.mp3?noCache={new Random().Next(0, 1000).ToString()}");

                    HtmlButton playButton = new HtmlButton();
                    var span = new HtmlGenericControl("i");
                    span.Attributes["class"] = "fa fa-fw fa-headphones";
                    playButton.Controls.Add(span);
                    playButton.Attributes.Add("class", "secondary-btn");
                    playButton.Attributes.Add("type", "button");
                    playButton.Attributes.Add("style", "width: 100%; min-width: 5em");
                    playButton.ClientIDMode = System.Web.UI.ClientIDMode.Static;
                    playButton.ID = r.StudentCWID + "PlayButton";
                    playButton.InnerText = "Play Back";
                    playButton.Attributes.Add("onClick", "play('" + r.StudentCWID + "');");
                    playCell.Controls.Add(play);
                    playCell.Controls.Add(playButton);

                    newRow.Controls.Add(CWIDcell);
                    newRow.Controls.Add(systemNameCell);
                    newRow.Controls.Add(preferredNameCell);
                    newRow.Controls.Add(phoneticCell);
                    newRow.Controls.Add(playCell);
                    newRow.TableSection = TableRowSection.TableBody;
                    recordingsList.Controls.Add(newRow);

                }
            }
        } 
    }
}