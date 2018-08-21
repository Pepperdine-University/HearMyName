using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DotNetCasClient;
using DotNetCasClient.Security;
using HearMyName.Helpers;

using System.IO;
using System.Web.Services;
using System.Web.Hosting;
using System.Diagnostics;
using System.Configuration;

namespace HearMyName
{
    public partial class Profile : System.Web.UI.Page
    {
        string Name;
        string CWID;
        string NTID;
        string systemName;
        string email;
        int recordingID;
        bool isNSO;


        protected void Page_Load(object sender, EventArgs e)
        {
            isNSO = string.IsNullOrEmpty(Request.QueryString["NSO"]) ? false : true;
            hdnIsNSO.Value = isNSO.ToString();

            ICasPrincipal p = HttpContext.Current.User as ICasPrincipal;
            CWID = p == null ? "1" : p.Assertion.Attributes["employeeID"][0];
            
            Name = getStudentNameFromCWID(CWID);
            systemName = p == null ? "Test Subject (REMOVE ME) SystemName" : p.Assertion.Attributes["displayName"][0];

            email = p == null ? "test@example.com" : p.Assertion.Attributes["mail"][0];
            NTID = p == null ? "test" : p.Assertion.Attributes["sAMAccountName"][0];
            
            if (Name.Count(x => x == ',')==1)
            {
                Name = Name.Split(',')[1] + " " + Name.Split(',')[0];
                Name = replaceEverythingInParenthesis(Name);
               
            }

            if (systemName.Count(x => x == ',') == 1)
            {
                systemName = systemName.Split(',')[1] + " " + systemName.Split(',')[0];
                systemName = replaceEverythingInParenthesis(systemName);
            }
            
            if (Helpers.HearMyNameHelper.isUserAnAdmin(Int32.Parse(CWID)))
            { 
                liReview.Visible = true;
            }

            Session.Add("CurrentUserID", CWID);

            hdnemail.Value = email;
            hdnNTID.Value = NTID;
            hdnStudentSystemName.Value = replaceEverythingInParenthesis(systemName);

            LoadData();
        }


        protected void LoadData()
        {
            if(isNSO)
            {
                btnUpdate.Value = "Save and Log Out";
            }

            int numericCWID = Int32.Parse(CWID);
            hdrMainHeader.InnerText = Name;
            using (var db = new HearMyNameEntities())
            {
                if (db.StudentRecordings.FirstOrDefault(A => A.StudentCWID == numericCWID) != null) //this is an update
                {
                    StudentRecording previousRecord = db.StudentRecordings.First(A => A.StudentCWID == numericCWID); 
                    if (!IsPostBack)
                    {
                        txtPreferredName.Value = previousRecord.StudentPreferredName.Replace("(student)", "");
                        txtPhoneticName.Value = previousRecord.Pronounciation;
                        if (audioPlayer.Src == null || audioPlayer.Src.Contains("Default"))
                            audioPlayer.Attributes["src"] = $"~/userfiles/converted/{CWID}.mp3?noCache={new Random().Next(0, 1000).ToString()}"; //the NoCache parameter just makes it so that the name looks different to the browser so it doesn't cache it. 
                        else
                            playButton.Disabled = true;
                    }

                    recordingID = previousRecord.ID;
                    hdnRecordingID.Value = recordingID.ToString();
                }
                else //This is a recording for a student has never done this before
                {
                    txtPreferredName.Value = Name;
                    playButton.Disabled = true;
                    hdnRecordingID.Value = "0";

                }
            }
        }

        private string getStudentNameFromCWID(string cwid)
        {
            ICasPrincipal p = HttpContext.Current.User as ICasPrincipal;
            string fullName = string.Empty;
            StudentInformation info = new StudentInformation();
            using (var db = new HearMyNameEntities())
            {
                 info = db.StudentInformations.FirstOrDefault(A => A.EMPLID.Equals(cwid.ToString().Trim()));
            }

            if (info==null)
            {
                fullName = (p == null ? "Test Subject 111" : p.Assertion.Attributes["displayName"][0]);
            }
            else
            {
                fullName = info.FIRST_NAME + ' ' + info.MIDDLE_NAME + ' ' + info.LAST_NAME;
            }


            return fullName;
        }

      



        [WebMethod]
        [System.Web.Script.Services.ScriptMethod()]
        public static string uploadRecording(bool ShouldRecordingGetUpdated, string recordingData, int recordingID, string email, string preferredName, string pronounciation, string studentSystemName, string NTID, string currentUserID, string userBrowser)
        {
            string ext = string.Empty;
            string newRecordingID = string.Empty;
            if (userBrowser.Equals("chrome") || userBrowser.Equals("android"))
                ext = "webm";
            else 
                ext = "ogg";
        
            try
            {       
                if (ShouldRecordingGetUpdated)
                {
                    byte[] data = Convert.FromBase64String(recordingData.Replace($"data:audio/{ext};base64,", ""));
                    short[] decodedData = new short[data.Length];
                    string fileName = HostingEnvironment.MapPath("~/userfiles/" + currentUserID + "." + ext);
                    File.WriteAllBytes(fileName, data); //first write the raw file to disk
                    ConvertRecording(currentUserID, ext);
                }

                newRecordingID= updateDatabase(recordingID, email, pronounciation, studentSystemName, NTID, preferredName, currentUserID );
               
            }
            catch(Exception ex)
            {
                string e = ex.ToString();
            }


            return newRecordingID;


        }
        

        protected  static void ConvertRecording(string cwid, string ext)
        {
        
            string environmentPath =  HostingEnvironment.MapPath("~/userfiles");

            if (File.Exists(environmentPath+@"\converted\" + cwid + ".mp3"))
            {
                
                File.Delete(environmentPath + @"\converted\" + cwid + ".mp3");
            }
            try
            {

               Process process = new Process
               {
                   StartInfo = {
                        FileName =  ConfigurationManager.AppSettings["ffmpegLocation"].ToString(),  // @"D:\Helpers\FileConversion\ffmpeg.exe",
                        Arguments = $@"-y -i {environmentPath}\{cwid}.{ext} -ar 22050 {environmentPath}\converted\{cwid}.mp3 "
                        ,RedirectStandardError=true
                        ,UseShellExecute=false
                        , WorkingDirectory=environmentPath
                   }
               };
                LogHelper.LogMessage("About to start converting");
                process.Start();
                string stdout = process.StandardError.ReadToEnd();
                process.WaitForExit();


                if (process.ExitCode == 0)
                    LogHelper.LogMessage("Just got done converting!");
                else
                    LogHelper.LogError("Process started, but ERROR HAPPENED: "+ stdout);

            }
            catch(Exception ex)
            {
                LogHelper.LogError("ERROR HAPPENED: " + ex.ToString());
            }
        }

        
        //copy the recording from the project directory to the file server (Waxmyrtle) and delete the current project directory copy. 
        //save/update db record for the student. 
        protected static string updateDatabase(int recordingID, string email,  string pronounciation, string studentSystemName, string NTID, string preferredName, string currentUserID)
        {
            int numericCWID = Int32.Parse(currentUserID);
            try
            {         
               
                using (var db = new HearMyNameEntities())
                {
                    string newRecodingID = string.Empty;
                    if (recordingID > 0) //a record exists, this is an UPdate
                    {
                        StudentRecording originalRecord = db.StudentRecordings.Find(recordingID);
                        originalRecord.StudentPreferredName = preferredName;
                        originalRecord.Pronounciation = pronounciation;

                        AppEvent newAppEvent = new AppEvent
                        {
                            RecordingID = recordingID,
                            ActionPerformed = "Updated recording",
                            NewStatus = "NotApproved",
                            PerformedBy = 1,
                            PerformedOn = DateTime.Now
                        };
                        db.AppEvents.Add(newAppEvent);
                       
                    }
                    else //this is a new record, inserrrrt!
                    {
                        StudentRecording newRecord = new StudentRecording
                        {
                            StudentCWID = int.Parse(currentUserID),
                            StudentNTID = NTID,
                            StudentName = studentSystemName,
                            StudentPreferredName = string.IsNullOrEmpty(preferredName) ? " " : preferredName,
                            Pronounciation = string.IsNullOrEmpty(pronounciation) ? " " : pronounciation,
                            StudentEmail = email,
                            CreatedBy = currentUserID,
                            CreatedOn = DateTime.Now
                        };
                        AppEvent newAppEvent = new AppEvent
                        {
                            ActionPerformed = "Created a new recording",
                            NewStatus = "NotApproved",
                            PerformedBy = 1,
                            PerformedOn = DateTime.Now
                        };

                        newRecord.AppEvents = new List<AppEvent>();
                        newRecord.AppEvents.Add(newAppEvent);
                        db.StudentRecordings.Add(newRecord);
                        

                    }
                    
                    db.SaveChanges();

                    StudentRecording previousRecord = db.StudentRecordings.First(A => A.StudentCWID == numericCWID);
                    

                    return previousRecord.ID.ToString();
                }
            }
            catch (Exception exe)
            {
                LogHelper.LogError(exe.ToString());
                return string.Empty;
            }
        }

        public string replaceEverythingInParenthesis(string input)
        {
            string returnValue = input;
            if(input.Contains("(") && input.Contains(")"))
            {
                int startIndex = input.IndexOf('(');
                int endIndex = input.IndexOf(')');

                returnValue = input.Remove(startIndex, endIndex - startIndex+1);
            }
            return returnValue;
        }


    }
}