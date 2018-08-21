<%@ Page Title="Hear My Name - Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="HearMyName.Profile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <ul class="menu right">
        <li id="liReview" runat="server" visible="false"><a href="Admin/Default.aspx">Review Recordings</a></li>
        <li><a href="HearNames.aspx">Hear Names</a></li>
        <li><a href="FAQ.aspx">FAQ</a></li>
        <li><a href="logout.aspx">Log Out</a></li>
    </ul>
    <h1 class="clearboth" runat="server" id="hdrMainHeader" clientidmode="static">My Profile</h1>
    <form runat="server">
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnRecordingID" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnNTID" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnemail" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnStudentSystemName" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="recordingUpdated" />
        <asp:HiddenField runat="server" ClientIDMode="Static" Value="false" ID="somethingIsUpdated" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnUserBrowser" />
        <asp:HiddenField runat="server" ClientIDMode="Static" ID="hdnIsNSO" />

        <fieldset class="full" id="instructionsDiv">
            <legend>Instructions
            </legend>
            <p>
                Please follow the three easy steps below (Record, Play Back, Save!) to record the correct pronunciation of your name. Once you click Record you will need to allow your browser access to the microphone.
            </p>
            <p>
                <b>*Graduating students, please record your full (first, middle, and last) name. You may direct any questions to your school's Dean's office.</b>
            </p>

        </fieldset>

        <fieldset class="full">
            <legend>Your information</legend>
            <asp:Label Font-Size="1em" CssClass="full clearleft" Text="<b>Please note: Adding a preferred name in this field does not change your official University record, nor will it be used for graduation. Graduating students, please see note at the top of this page.</b><br/>" runat="server" />

            <label for="preferred-name" class="fourth clearleft">Preferred Name</label>

            <input id="txtPreferredName" type="text" onfocus="enableUploadButton();" clientidmode="static" class="half" runat="server" value="" />


            <label for="phonetic-name" class="fourth clearleft">Phonetic Pronunciation (Optional)</label>
            <input id="txtPhoneticName" type="text" onfocus="enableUploadButton();" clientidmode="static" class="half" runat="server" value="" />

            <label class="clearleft step-num">1</label>
            <button type="button" class="fourth secondary-btn  button-list" id="recordButton" onclick="startRecording()" clientidmode="static" runat="server"><i class="fa fa-fw fa-microphone"></i>Record</button>
            <p class="third">
                <canvas id="meter" width="300" style="border: solid" height="50"></canvas>
                <!--this is the visual sound meter dealie. make sure the id doesn't change or it won't work!-->
            </p>          
            <label class="clearleft step-num">2</label>
            <button type="button" class="fourth secondary-btn button-list" id="playButton" onclick="play();" clientidmode="static" runat="server"><i class="fa fa-fw fa-headphones"></i>Play Back</button>
            <label class="clearleft step-num">3</label>
            <input type="button" id="btnUpdate" clientidmode="Static" disabled="disabled" class="fourth button-list" runat="server" onclick="uploadAJAXAudio(); return false;" value="Save" />
            <audio src="/userfiles/DefaultNoRecord.webm" id="audioPlayer" clientidmode="static" runat="server"></audio>

        </fieldset>
        <div id="countdownBanner" class="theFinalCountdown">Ready</div>
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
    </form>
    <script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
    <script src="Content/JS/volume-meter.js"></script>
    <script>
        const constraints = { "video": false, "audio": true };
        var theStream;
        var theRecorder;
        var recordedChunks = [];
        var audioContext = null;
        var meter = null;
        var canvasContext = null;
        var mediaStreamSource = null
        var WIDTH = 500;
        var HEIGHT = 50;
        var numChannels = 1;
        var sampleRate = 44100;
        var browser;

        window.onload = function () {
            detectBrowser();

            $("#userBrowser").text(browser);

            if (!(browser == 'chrome' || browser == 'android' || browser == 'firefox'))
                showBrowserError();

            var audio = document.getElementById("audioPlayer");
            canvasContext = document.getElementById("meter").getContext("2d");
            // monkeypatch Web Audio
            window.AudioContext = window.AudioContext || window.webkitAudioContext;

            // grab an audio context
            audioContext = new AudioContext();
            audio.addEventListener('ended', stopAudioPlayback);
            audio.load(); // setting the source in the codebehind doesn't seem to work consistantly without triggering Load on clientside. 


        }


        function detectBrowser() {

            if (navigator.userAgent.match(/Android/i)) {
                browser = 'android';
            }
            else if (navigator.userAgent.match(/iPhone/i)
                || navigator.userAgent.match(/iPad/i)
                || navigator.userAgent.match(/iPod/i)) {
                browser = 'iphone';
            }
            // Opera 8.0+
            else if ((!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0)
                browser = 'opera';
            // Firefox 1.0+
            else if (typeof InstallTrigger !== 'undefined')
                browser = 'firefox';
            // Safari 3.0+ "[object HTMLElementConstructor]" 
            else if (/constructor/i.test(window.HTMLElement) || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || (typeof safari !== 'undefined' && safari.pushNotification)))
                browser = 'safari';
            // Internet Explorer 6-11
            else if  /*@cc_on!@*/(false || !!document.documentMode)
                browser = 'ie';
            // Edge 20+
            else if (!!window.StyleMedia) //the order of browser checks is important, as this HAS to follow the IE check above to be succesful. 
                browser = 'edge';
            // Chrome 1+
            else if (!!window.chrome && !!window.chrome.webstore)
                browser = 'chrome';
            // Blink engine detection
            else if ((isChrome || isOpera) && !!window.CSS)
                broser = 'blink';
            else
                browser = 'unknown';



        }



        function startRecording() {
            try {
                navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
                navigator.mediaDevices.getUserMedia(constraints).then(countdownStart);
            }
            catch (e) {
                console.error('getUserMedia() failed: ' + e);
            }


        }

        function countdownStart(stream) {
            var recordButton = document.getElementById("recordButton");
            recordButton.style.background = "#FF5555";
            recordButton.innerHTML = "Stop";
            recordButton.onclick = stopRecording;
            popCountdown("Ready");
            setTimeout(function () { popCountdown("Set") }, 1000);
            setTimeout(function () { popCountdown("Go") }, 2000);
            setTimeout(function () { gotMedia(stream) }, 2500);

            setTimeout(stopRecording, 10000);//this is to limit the recording to 10 seconds. 
        }

        function gotMedia(stream) {
            recordedChunks = [];
            theStream = stream;
            mediaStreamSource = audioContext.createMediaStreamSource(stream);



            // Create a new volume meter and connect it.
            meter = createAudioMeter(audioContext);
            mediaStreamSource.connect(meter);


            try {
                if (browser == 'chrome' || browser == 'android')
                    recorder = new MediaRecorder(stream, { mimeType: "audio/webm" }); //this has to be audio/webm for chrome and audio/ogg for firefox. 
                else if (browser == 'firefox')
                    recorder = new MediaRecorder(stream, { mimeType: "audio/ogg" });
                else
                    showBrowserError();

            } catch (e) {
                alert("Error reaching the audio device. Please make sure you're using either Chrome or Firefox and that your browser is up to date." + e)
                console.error('Exception while creating MediaRecorder: ' + e);
                return;
            }



            theRecorder = recorder;
            recorder.ondataavailable =
                (event) => { recordedChunks.push(event.data); };
            recorder.start(100);
            drawLoop(); //starts visual updating. 
        }



        function stopRecording() {
            $("#recordingUpdated").val("true");


            saveRecordedSound();
            var recordButton = document.getElementById("recordButton");
            recordButton.style.background = "#ededed";
            recordButton.onclick = startRecording;
            recordButton.innerHTML = "Record";
            $("#playButton").prop("disabled", false);
            $("#btnUpdate").prop("disabled", false);
        }

        function saveRecordedSound() {
            var blob
            enableUploadButton();
            theRecorder.stop();
            theStream.getTracks().forEach(track => { track.stop(); });
            if (browser == 'chrome' || browser == 'android')
                blob = new Blob(recordedChunks, { type: "audio/webm" });
            else if (browser == 'firefox')
                blob = new Blob(recordedChunks, { type: "audio/ogg" });


            var audio = document.getElementById("audioPlayer");
            audio.src = window.URL.createObjectURL(blob);
            audio.load();

        }

        function play() {
            var audio = document.getElementById("audioPlayer");
            var playButton = document.getElementById("playButton");
            var recordButton = document.getElementById("recordButton");
            var updateButton = document.getElementById("btnUpdate");

            audio.pause();          //this line and the one below just make sure that the recording starts from the beginning each time Play is clicked. 
            audio.currentTime = 0;
            audio.play();
            playButton.onclick = stopAudioPlayback;
            playButton.style.background = "#b2e57b";
            playButton.innerHTML = "Stop";



        }

        function stopAudioPlayback() {
            var audio = document.getElementById("audioPlayer");
            var playButton = document.getElementById("playButton");
            var recordButton = document.getElementById("recordButton");
            var updateButton = document.getElementById("btnUpdate");
            audio.pause();
            audio.currentTime = 0;
            playButton.onclick = play;
            playButton.style.background = "#ededed";
            playButton.innerHTML = "Play Back";


        }


        function showBrowserError() {
            $("#divBrowserIssue").show(200);
            $("#loadingBG").show();
        }


        function showLoading() {
            $("#divLoading").show(200);
            $("#loadingBG").show();
        }

        function hideLoading() {
            var isNSO = $("#hdnIsNSO").val();
            $("#divLoading").hide(200);
            $("#loadingBG").hide();

            if (isNSO == 'True')//if this is NSO, logout!
            {
                $(location).attr('href', "../logout.aspx?nso=true");

            }
        }

        function uploadAJAXAudio() {


            showLoading();
            somethingChanged();
            var blob;
            var shouldUpdateRecording = $("#recordingUpdated").val() || 'false';
            if (browser == 'chrome' || browser == 'android')
                blob = new Blob(recordedChunks, { type: "audio/webm" });
            else if (browser == 'firefox')
                blob = new Blob(recordedChunks, { type: "audio/ogg" });

            var currentUserID = '<%=Session["CurrentUserID"] %>';

            var data = new FormData();
            data.append('file', blob);
            var arrayBuffer;
            var fileReader = new FileReader();
            fileReader.onload = function () {
                arrayBuffer = this.result;
            };
            fileReader.readAsArrayBuffer(blob);

            var reader = new FileReader();
            if (blob) {
                reader.readAsDataURL(blob);
            }


            reader.addEventListener("loadend", function () {
                PageMethods.uploadRecording(shouldUpdateRecording, reader.result, $("#hdnRecordingID").val(), $("#hdnemail").val(), $("#txtPreferredName").val(), $("#txtPhoneticName").val(), $("#hdnStudentSystemName").val(), $("#hdnNTID").val(), currentUserID, browser, handleRecordingUpdateComplete);
            }, false);

        }

        function handleRecordingUpdateComplete(recordingID) {
            $("#hdnRecordingID").val(recordingID);
            hideLoading();
        }




        function somethingChanged() {
            var updateButton = $("#btnUpdate");
            updateButton.prop("disabled", true);
        }

        function enableUploadButton() {
            var updateButton = $("#btnUpdate");
            updateButton.prop("disabled", false);
        }


        //this is not used, jsut a way to triggere the visualizer. 
        function startVisualizer() {
            var meter = createAudioMeter(audioContext, clipLevel, averaging, clipLag);

        }

        function drawLoop(time) {
            // clear the background
            canvasContext.clearRect(0, 0, WIDTH, HEIGHT);

            // check if we're currently clipping
            if (meter.checkClipping())
                canvasContext.fillStyle = "red";
            else
                canvasContext.fillStyle = "green";

            // draw a bar based on the current volume
            canvasContext.fillRect(0, 0, meter.volume * WIDTH * 1.4, HEIGHT);

            // set up the next visual callback
            rafID = window.requestAnimationFrame(drawLoop);
        }

        function popCountdown(message) {
            $("#countdownBanner").text(message);
            $("#countdownBanner").show("fade", 700);
            $("#countdownBanner").hide("fade", 300);
        }

        function sleep(milliseconds) {
            var start = new Date().getTime();
            for (var i = 0; i < 1e7; i++) {
                if ((new Date().getTime() - start) > milliseconds) {
                    break;
                }
            }
        }


    </script>


</asp:Content>
