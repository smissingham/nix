// ==UserScript==
// @name         Glyphic Scrape Transcripts
// @namespace    http://tampermonkey.net/
// @version      2025-08-15
// @description  Bulk downloads transcripts from glyphics companies activity page
// @author       Sean Missingham
// @match        https://app.glyphic.ai/companies/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// ==/UserScript==
const WAITMS = 1500;
(function () {
  "use strict";

  class GlyphicScraper {
    constructor() {
      this.capturedXhrData = [];
      this.isInterceptActive = false;
      this.sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    }

    init() {
      this.injectDownloadButton();
    }

    setupNetworkIntercept() {
      if (this.isInterceptActive) return;

      console.log("🔧 Setting up network intercept...");

      const originalXHROpen = XMLHttpRequest.prototype.open;
      const originalXHRSend = XMLHttpRequest.prototype.send;

      XMLHttpRequest.prototype.open = function (method, url, ...args) {
        this._interceptedUrl = url;
        return originalXHROpen.apply(this, [method, url, ...args]);
      };

      XMLHttpRequest.prototype.send = function (...args) {
        const xhr = this;
        if (this._interceptedUrl) {
          this.addEventListener("loadend", function () {
            if (xhr.status === 200 && xhr.responseText) {
              window.glyphicScraper.capturedXhrData.push({
                url: xhr._interceptedUrl,
                data: xhr.responseText,
              });
            }
          });
        }
        return originalXHRSend.apply(this, args);
      };

      this.isInterceptActive = true;
      window.glyphicScraper = this;
      console.log("✅ Network intercept ready");
    }

    async ensureActivityTab() {
      if (!window.location.search.includes("tab=activity")) {
        console.log("📍 Navigating to activity tab...");
        let url = new URL(window.location);
        url.searchParams.set("tab", "activity");
        window.location.replace(url.toString());
        return false; // Indicates navigation occurred
      }
      return true; // Already on activity tab
    }

    getCallList() {
      return Array.from(document.querySelectorAll('div > div[id^="6"]'));
    }

    async waitForCallList() {
      return new Promise((resolve) => {
        const check = () => {
          const calls = this.getCallList();
          if (calls.length > 0) {
            resolve(calls);
          } else {
            setTimeout(check, 100);
          }
        };
        check();
      });
    }

    parseXhrData(xhr) {
      const callsDataRegex = /.*calls\/(.*)/;
      const url = xhr.url;
      const matchGroup = url.match(callsDataRegex)?.[1];
      const dataPath = matchGroup?.split("/")?.[1];

      // transcript xhr item has full call path minus suffixed data path
      if (matchGroup && !dataPath) {
        try {
          const data = JSON.parse(xhr.data);

          const title = data.title || "Untitled Call";
          const durationSecs = data.duration || 0;
          const startDate = data.start_time
            ? new Date(data.start_time)
            : new Date();

          const people =
            data.parties?.reduce((acc, party) => {
              acc[party.id] = `${party.name} (${party.email})`;
              return acc;
            }, {}) || {};

          const transcriptText =
            data.transcript_turns
              ?.map((speech) => {
                const person = people[speech.speaker] || "Unknown Speaker";
                return `[(${person}) @ ${speech.timestamp}]: ${speech.turn_text}`;
              })
              .join("\n\n") || "No transcript available";

          return {
            title,
            durationSecs,
            startDate,
            people,
            transcriptText,
          };
        } catch (error) {
          console.error("Failed to parse XHR data:", error);
          return null;
        }
      }
      return null;
    }

    downloadParsedData(parsedData) {
      const markdown = `---
title: ${parsedData.title}
durationSecs: ${parsedData.durationSecs}
startDate: ${parsedData.startDate}
---
# People
${Object.entries(parsedData.people)
  .map(([id, info]) => `- ${info}`)
  .join("\n")}

# Transcript
${parsedData.transcriptText}
`;

      const filename =
        this.sanitizeFilename(parsedData.title) + "-transcript.md";
      this.downloadTextFile(markdown, filename);
    }

    sanitizeFilename(filename) {
      return filename.replace(/[^a-z0-9]/gi, "_").toLowerCase();
    }

    downloadTextFile(text, filename = "file.txt") {
      const blob = new Blob([text], { type: "text/plain" });
      const url = URL.createObjectURL(blob);

      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      a.click();

      URL.revokeObjectURL(url);
    }

    async downloadAllTranscripts() {
      console.clear();
      console.log("🚀 Starting transcript download process...");

      this.setupNetworkIntercept();

      // Ensure we're on the activity tab
      if (!(await this.ensureActivityTab())) {
        return; // Navigation occurred, script will restart
      }

      // Store the base URL for returning
      const baseUrl = window.location.href;
      console.log("📍 Base URL:", baseUrl);

      // Wait for call list to load
      const callList = await this.waitForCallList();
      console.log(`📞 Found ${callList.length} calls`);

      if (callList.length === 0) {
        console.log("❌ No calls found");
        return;
      }

      let successCount = 0;
      let errorCount = 0;

      for (let index = 0; index < callList.length; index++) {
        try {
          console.log(`\n📋 Processing call ${index + 1}/${callList.length}`);

          // Clear previous data
          this.capturedXhrData.length = 0;

          // Get fresh call list (DOM may have changed)
          const currentCallList = this.getCallList();
          const callElement = currentCallList[index];
          const callTitle = callElement?.querySelector("span");

          if (!callTitle) {
            console.log(`❌ Call ${index + 1} element not found`);
            errorCount++;
            continue;
          }

          console.log(`🖱️  Clicking: ${callTitle.textContent}`);
          callTitle.click();

          // Wait for navigation and data to load
          await this.sleep(WAITMS);

          // Process captured data
          const parsedData = this.capturedXhrData
            .map((xhr) => this.parseXhrData(xhr))
            .filter((data) => data !== null);

          if (parsedData.length > 0) {
            console.log(`💾 Downloading ${parsedData.length} transcript(s)`);
            parsedData.forEach((data) => this.downloadParsedData(data));
            successCount++;
          } else {
            console.log(`⚠️  No transcript data found for call ${index + 1}`);
            errorCount++;
          }

          // Navigate back using pushState to base URL
          console.log("⬅️  Navigating back to base URL...");
          window.history.pushState({}, "", baseUrl);

          // Trigger a popstate event to make SPA react
          window.dispatchEvent(new PopStateEvent("popstate", { state: {} }));

          // Wait longer for SPA to react and DOM to settle
          await this.sleep(WAITMS);
          await this.waitForCallList();
        } catch (error) {
          console.error(`❌ Error processing call ${index + 1}:`, error);
          errorCount++;

          // Try to recover by going back to base URL
          try {
            console.log("🔄 Attempting recovery...");
            window.history.pushState({}, "", baseUrl);
            window.dispatchEvent(new PopStateEvent("popstate", { state: {} }));
            await this.sleep(WAITMS);
            await this.waitForCallList();
          } catch (recoveryError) {
            console.error("Failed to recover, stopping process");
            break;
          }
        }
      }

      console.log(
        `\n✅ Process complete: ${successCount} successful, ${errorCount} errors`,
      );
    }

    injectDownloadButton() {
      const btn = document.createElement("button");
      btn.innerHTML = `
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
          <polyline points="7,10 12,15 17,10"/>
          <line x1="12" y1="15" x2="12" y2="3"/>
        </svg>
      `;

      Object.assign(btn.style, {
        position: "fixed",
        top: "20px",
        right: "20px",
        width: "50px",
        height: "50px",
        backgroundColor: "#007bff",
        color: "white",
        border: "none",
        borderRadius: "50%",
        cursor: "pointer",
        zIndex: "10000",
        boxShadow: "0 4px 12px rgba(0,0,0,0.3)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        transition: "all 0.2s ease",
      });

      btn.onmouseenter = () => {
        btn.style.backgroundColor = "#0056b3";
        btn.style.transform = "scale(1.1)";
      };

      btn.onmouseleave = () => {
        btn.style.backgroundColor = "#007bff";
        btn.style.transform = "scale(1)";
      };

      btn.onclick = () => this.downloadAllTranscripts();

      document.body.appendChild(btn);
      console.log("📌 Download button injected");
    }
  }

  // Initialize the scraper
  const scraper = new GlyphicScraper();
  scraper.init();
})();
