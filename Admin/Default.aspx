<%@ Page Title="Hear My Name - Admin" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HearMyName.Admin" %>




<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script>


    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <ul class="menu right">
        <li><a href="../HearNames.aspx">Hear Names</a></li>
        <li><a href="../Profile.aspx">My Profile</a></li>
        <li><a href="../FAQ.aspx">FAQ</a></li>
        <li><a href="../logout.aspx">Log Out</a></li>
    </ul>
    <h1 class="clearboth">Admin Panel</h1>
    <form runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    <asp:Table class="full" ID="recordingsList" ClientIDMode="static" runat="server">
        <asp:TableHeaderRow TableSection="TableHeader">
                <asp:TableHeaderCell style="width: 10%" >CWID</asp:TableHeaderCell>
                <asp:TableHeaderCell style="width: 20%">System Name</asp:TableHeaderCell>
                <asp:TableHeaderCell style="width: 20%">Preferred Name</asp:TableHeaderCell>
                <asp:TableHeaderCell style="width: 20%">Phonetic Pronunciation</asp:TableHeaderCell>
                <asp:TableHeaderCell class="text-center" style="width: 15%">Hear the Name</asp:TableHeaderCell>
                <asp:TableHeaderCell class="text-center" style="width: 5%">Reviewed</asp:TableHeaderCell>        
        </asp:TableHeaderRow>

    </asp:Table>
    </form>
    <style type="text/css">
        .largerCheckbox input
        {   
            width: 2em;         
            height: 2em;
        }
    </style>
    <script>
        $(document).ready(function () {
            $("#recordingsList").DataTable({
                paging: false, 
                "columns":[null, null, null, null, null,  { "orderDataType": "dom-checkbox" }] }
            );
            $(".AudioControl").each(function () {
                $(this).on('ended', function () { stopAudioPlayback(this.id); });
            });

        });

        $.fn.dataTable.ext.order['dom-checkbox'] = function  ( settings, col )
        {
            return this.api().column( col, {order:'index'} ).nodes().map( function ( td, i ) {
                return $('input', td).prop('checked') ? '1' : '0';
            });
        }


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

        function updateCheckedStatus(CWID)
        {
            var checkbox = $("#chk" + CWID);
            PageMethods.updateReviewedStatus(checkbox.prop('checked'), CWID);

        }
    </script>
</asp:Content>
