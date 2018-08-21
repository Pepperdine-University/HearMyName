using DotNetCasClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace HearMyName
{
    public partial class Admin : System.Web.UI.Page
    {
        private string userRole;

        protected void Page_Load(object sender, EventArgs e)
        {
            int cwid = CasAuthentication.CurrentPrincipal == null ? 100 :
                                    Int32.Parse(CasAuthentication.CurrentPrincipal.Assertion.Attributes["employeeID"][0]);

            if (Helpers.HearMyNameHelper.isUserAnAdmin(cwid))
            {
                using (var db = new HearMyNameEntities())
                {

                    foreach (LatestRecordingStatus r in db.LatestRecordingStatuses)
                    {
                        TableRow newRow = new TableRow();

                        TableCell CWIDcell = new TableCell();
                        TableCell systemNameCell = new TableCell();
                        TableCell preferredNameCell = new TableCell();
                        TableCell phoneticCell = new TableCell();
                        TableCell playCell = new TableCell();
                        TableCell reviewCell = new TableCell();

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

                        //Review Cell: 
                        reviewCell.CssClass = "text-center";
                        CheckBox chkIsReviewed = new CheckBox();
                        chkIsReviewed.Checked = r.isReviewed ?? false;
                        chkIsReviewed.ID = "chk" + r.ID;
                        chkIsReviewed.CssClass = "largerCheckbox";
                        chkIsReviewed.ClientIDMode = ClientIDMode.Static;
                        chkIsReviewed.Attributes["onClick"] = "updateCheckedStatus(" + r.ID + ")";
                        reviewCell.Controls.Add(chkIsReviewed);

                        newRow.Controls.Add(CWIDcell);
                        newRow.Controls.Add(systemNameCell);
                        newRow.Controls.Add(preferredNameCell);
                        newRow.Controls.Add(phoneticCell);
                        newRow.Controls.Add(playCell);
                        newRow.Controls.Add(reviewCell);
                        newRow.TableSection = TableRowSection.TableBody;
                        recordingsList.Controls.Add(newRow);

                    }

                }
            }
            else //the current user is not an admin and shouldn't be messing with the review console. 
            {
                Server.Transfer("../HearNames.aspx");
            }
        }


        [WebMethod]
        [System.Web.Script.Services.ScriptMethod()]
        public static void updateReviewedStatus(bool isReviewed, int CWID)
        {
            try
            {
                using (var db = new HearMyNameEntities())
                {

                    StudentRecording originalRecord = db.StudentRecordings.Find(CWID);
                    originalRecord.isReviewed = isReviewed;
                    db.SaveChanges();


                }
            }
            catch (Exception ex)
            {
                
            }
        }
    }
}