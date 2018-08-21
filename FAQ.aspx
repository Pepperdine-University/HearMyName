<%@ Page Title="Hear My Name - Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FAQ.aspx.cs" Inherits="HearMyName.FAQ" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">


    <ul class="menu right">
        <li id="liReview" runat="server" visible="false"><a href="Admin/Default.aspx">Review Recordings</a></li>
        <li><a href="HearNames.aspx">Hear Names</a></li>
        <li><a href="FAQ.aspx">FAQ</a></li>
        <li><a href="logout.aspx">Log Out</a></li>
    </ul>
    <h1 class="clearboth" runat="server" id="hdrMainHeader" clientidmode="static">Hear My Name FAQs</h1>


    <div id="accordion" class="full ">
        <h3>Add FAQ items below</h3>
        <div>
            <p>
                FAQ question                
            </p>
        </div>
       

    </div>

    <script>
        $(document).ready(function () {
            var recordingTable = $("#recordingsList").DataTable({
                paging: false,
                order: [[1, 'asc']]
            });

            $("#accordion").accordion({
                collapsible: true
                , active: false


            });
        });

    </script>

</asp:Content>
