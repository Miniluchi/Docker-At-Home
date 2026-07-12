const qbtUser = encodeURIComponent(process.env.QBT_USER || "");
const qbtPass = encodeURIComponent(process.env.QBT_PASS || "");

module.exports = {
  torznab: (process.env.CROSS_SEED_TORZNAB || "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean),
  torrentClients: [`qbittorrent:http://${qbtUser}:${qbtPass}@gluetun:8080`],
  useClientTorrents: true,
  dataDirs: ["/data/Downloads"],
  linkDirs: ["/data/cross-seed-links"],
  linkType: "hardlink",
  matchMode: "flexible",
  action: "inject",
  port: 2468,
  apiKey: process.env.CROSS_SEED_APIKEY || undefined,
  rssCadence: "30 minutes",
  searchCadence: "1 week",
  excludeRecentSearch: "3 weeks",
  excludeOlder: "8 weeks",
};
