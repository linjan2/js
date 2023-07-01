function getItemDescription(item) {
  let description = 
    item.getElementsByTagName("description")?.[0]?.textContent
    ?? item.getElementsByTagName("summary")?.[0]?.textContent
    ?? item.getElementsByTagName("content")?.[0]?.textContent
    ?? null;
  if (description) {
    const htmlDoc = (new DOMParser()).parseFromString(description, "text/html");
    return htmlDoc.documentElement.textContent;
    // let element = document.createElement("div");
    // element.innerHTML = description;
    // return element.innerText;
  } else {
    return null;
  }
}

function fetchFeed(feed) {
  feed.status = "loading";
  return fetch(feed.url).then(response => {
    if (response.ok) {
      return response.text();
    } else {
      throw new Error(response);
    }
  }).then((xml) => {
    const xmlDoc = (new DOMParser()).parseFromString(xml, "text/xml");
    let parseerror = xmlDoc.querySelector("parsererror");
    let title;
    let items = [];
    if (null === parseerror) {
      if (xmlDoc.firstElementChild.nodeName === "feed") {
        // Atom format
        title = xmlDoc.querySelector("feed>title")?.textContent.trim() ?? "";
        xmlDoc.querySelectorAll("feed>entry").forEach((item) => {
          items.push({
            title: item.getElementsByTagName("title")?.[0]?.textContent.trim() ?? "",
            link: item.getElementsByTagName("link")?.[0]?.getAttribute("href") ?? "",
            description: getItemDescription(item),
            date: item.getElementsByTagName("updated")?.[0]?.textContent.trim() ?? ""
          });
        });
      } else if (xmlDoc.firstElementChild.nodeName === "rss") {
        // RSS format
        title = xmlDoc.querySelector("rss>channel>title")?.textContent ?? "";
        xmlDoc.querySelectorAll("rss>channel>item").forEach((item) => {
          items.push({
            title: item.getElementsByTagName("title")?.[0]?.textContent.trim() ?? "",
            link: item.getElementsByTagName("link")?.[0]?.textContent.trim() ?? "",
            description: getItemDescription(item),
            date: item.getElementsByTagName("pubDate")?.[0]?.textContent.trim() ?? ""
          });
        });
      } else {
        console.error("Missing <feed>/<rss> in XML document", xmlDoc);
        throw new Error(xmlDoc);
      }
    } else {
      console.error("parsererror", parseerror);
      throw new Error(parseerror);
    }

    Object.assign(feed, {title, items, status: "loaded"});
    return new Promise(resolve => resolve(feed));
  }).catch((e) => {
    console.warning("catch", e);
    Object.assign(feed, {status: "failed"});
    return new Promise(resolve => resolve(feed));
  });
}

PetiteVue.createApp({
  // urls: [
  // "http://localhost:8080/pandoc/reddit.rss",
  // "http://localhost:8080/pandoc/red-hat-enterprise-linux.rss",
  // "https://mastodon.social/@bagder.rss",
  // "http://localhost:8080/pandoc/bagder.rss",
    
  // "https://nitter.net/bagder/rss"
  // "https://www.youtube.com/feeds/videos.xml?channel_id=UC7noUdfWp-ukXUlAsJnSm-Q" // Red Hat Developers
  // https://www.nist.gov/blogs/taking-measure/rss.xml // NIST Blog
  // ],
  feeds: [
    {
      name: "Daniel Stenberg @bagder",
      url: "http://localhost:8080/pandoc/nitter.rss",
      status: "unloaded"
    },
    {
      name: "RHEL",
      url: "http://localhost:8080/pandoc/red-hat-enterprise-linux.rss",
      status: "unloaded"
    },
    {
      name: "Reddit",
      url: "http://localhost:8080/pandoc/reddit.rss",
      status: "unloaded"
    }
    // { // the kubernetes-security-announce group for security and vulnerability announcements
    //   url: "https://groups.google.com/forum/feed/kubernetes-security-announce/msgs/rss_v2_0.xml?num=50",
    // },
    // { // the kubernetes-security-announce group for security and vulnerability announcements
    //   url: "https://www.us-cert.gov/ncas/bulletins.xml",
    // },

  ],
  // items: [],
  // select() {
  //   let that = this;
  //   setTimeout(()=> {
  //     that.reload();
  //   }, 0);
  // },
  expandFeed(feed) {
    if (feed.status === "unloaded") {
      fetchFeed(feed);
    }
  },
  mounted() {
    console.debug("mounted");
    // let that = this;
    // this.feeds.forEach((feed) => {
    //   fetchFeed(feed.url).then((f) => Object.assign(feed, f));
    // });
  }
}).mount("#rss-app");
