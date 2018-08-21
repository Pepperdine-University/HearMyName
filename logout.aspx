<%@ Page Title="Hear My Name - Logout" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="logout.aspx.cs" Inherits="HearMyName.Logout" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="full">
        <h1>Logout Successful</h1>
        <p>You have successfully logged out.</p>
        <p><a href="<%= ResolveUrl("~/") %>">Click here</a> to log in again.</p>
    </div>
</asp:Content>