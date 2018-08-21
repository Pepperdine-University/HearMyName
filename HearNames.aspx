<%@ Page Title="Hear My Name - Admin" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HearNames.aspx.cs" Inherits="HearMyName.HearNames" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .buttonLink {
            color: white !important;
            padding: 5px 10px 5px 10px;
            background-color: #e87223;
            transition: all 350ms;
        }

            .buttonLink:hover {
                background-color: #bc550f;
            }
    </style>
    <form runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        <ul class="menu right">
            <li id="liReview" runat="server" visible="false"><a href="Admin/Default.aspx">Review Recordings</a></li>
            <li><a href="Profile.aspx">My Profile</a></li>
            <li><a href="FAQ.aspx">FAQ</a></li>
            <li><a href="logout.aspx">Log Out</a></li>
        </ul>
        <div id="accordion" class="full clearboth">
            <h3 id="bulkSearchHeader">Bulk Search</h3>
            <div>
                <p>
                    <label class="full" for="groupSearchTextBox"><b>Please insert one or more CWIDs to perform a bulk search:</b></label>
                    <textarea class="full" id="groupSearchTextBox" clientidmode="static" runat="server"></textarea>
                </p>     
                <button onclick="redirectBulkSearch(); return false;">Save Bulk Search</button>
         
            </div>
        </div>
        <h1 class="clearboth">Name Recording Directory</h1>
        <asp:Table class="full" ID="recordingsList" ClientIDMode="static" runat="server">
            <asp:TableHeaderRow TableSection="TableHeader">
                <asp:TableHeaderCell Style="width: 10%">CWID</asp:TableHeaderCell>
                <asp:TableHeaderCell Style="width: 20%">System Name</asp:TableHeaderCell>
                <asp:TableHeaderCell Style="width: 20%">Preferred Name</asp:TableHeaderCell>
                <asp:TableHeaderCell Style="width: 15%">Phonetic Pronunciation</asp:TableHeaderCell>
                <asp:TableHeaderCell CssClass="text-center" Style="width: 15%">Hear the Name</asp:TableHeaderCell>
            </asp:TableHeaderRow>
        </asp:Table>
        <script>   
            $(document).ready(function () {
                if (sessionStorage.getItem("saveBulkSearch") == "true") {
                    bookmark();
                    sessionStorage.setItem("saveBulkSearch", "false");
                }




                var recordingTable = $("#recordingsList").DataTable({
                    paging: false,
                    order: [[1, 'asc']]
                });

                $("#accordion").accordion({
                    collapsible: true
                    , active: false
                    , heightStyle: "content"
                    , autoHeight: false
                    , clearStyle: true
                });

                $("#saveBulkSearchAccordion").accordion({
                    collapsible: true
                    , active: false
                    , heightStyle: "content"
                    , autoHeight: false
                    , clearStyle: true
                });



                $("#bulkSearchHeader").on("click", function () {
                    $("#groupSearchTextBox").val('');
                    recordingTable.draw();
                });

                $(".AudioControl").each(function () {
                    $(this).on('ended', function () { stopAudioPlayback(this.id); });
                });

                //this will refresh the search table every time there is a change in the bulk search field. 
                $("#groupSearchTextBox").on("input", function () {
                    recordingTable.draw();
                });

                $.fn.dataTable.ext.search.push(
                    function (settings, data, dataIndex) {

                        var filterQuery = $("#groupSearchTextBox").val();
                        var saveBulkSearchLink = $("#lnkSaveBulkSearch");


                        saveBulkSearchLink.attr("href", window.location.href + "?BulkSearch=" + encodeURIComponent(btoa(filterQuery)));
        
                        var CWID = parseFloat(data[0]) || ''; // use data for the age column

                        if (filterQuery == '' ||
                            filterQuery.includes(CWID)) {
                            return true;
                        }
                        return false;
                    }
                );
            });



            function stopAudioPlayback(value) {
                var cwid = value.match(/\d+/)[0];
                var audio = document.getElementById(cwid + "Audio");
                var playButton = document.getElementById(cwid + "PlayButton");
                audio.pause();
                audio.currentTime = 0;
                playButton.onclick = function () { play(cwid); };
                playButton.style.background = "#ededed";
                playButton.innerHTML = "Play Back";

            }
            function play(cwid) {
                var audio = document.getElementById(cwid + "Audio");
                var playButton = document.getElementById(cwid + "PlayButton");
                audio.pause();          //this line and the one below just make sure that the recording starts from the beginning each time Play is clicked. 
                audio.currentTime = 0;
                audio.play();
                playButton.onclick = function () { stopAudioPlayback(cwid); };
                playButton.style.background = "#b2e57b";
                playButton.innerHTML = "Stop";
            }

            function redirectBulkSearch() {
                var filterQuery = $("#groupSearchTextBox").val();
                sessionStorage.setItem("saveBulkSearch", "true");
                window.location.href =removeURLParameter( window.location.pathname,"ticket") + "?BulkSearch=" + encodeURIComponent(btoa(filterQuery));
                return false;
            }

            function bookmark() {
                var bookmarkURL = $("#lnkSaveBulkSearch").href;
                var bookmarkTitle = "HearMyName Saved Group Search";

                if ('addToHomescreen' in window && addToHomescreen.isCompatible) {
                    // Mobile browsers
                    addToHomescreen({ autostart: false, startDelay: 0 }).show(true);

                } else if (window.external && ('AddFavorite' in window.external)) {
                    // IE Favorites
                    window.external.AddFavorite(bookmarkURL, bookmarkTitle);
                } else {
                    // Other browsers (mainly WebKit & Blink - Safari, Chrome, Opera 15+)
                    alert('Press ' + (/Mac/i.test(navigator.userAgent) ? 'Cmd' : 'Ctrl') + '+D to bookmark this page.');
                }

                return false;
            }



            function removeURLParameter(url, parameter) {              
                var urlparts = url.split('?');
                if (urlparts.length >= 2) {

                    var prefix = encodeURIComponent(parameter) + '=';
                    var pars = urlparts[1].split(/[&;]/g);                    
                    for (var i = pars.length; i-- > 0;) {
                        if (pars[i].lastIndexOf(prefix, 0) !== -1) {
                            pars.splice(i, 1);
                        }
                    }
                    url = urlparts[0] + (pars.length > 0 ? '?' + pars.join('&') : "");
                    return url;
                } else {
                    return url;
                }
            }

        </script>
    </form>
</asp:Content>
