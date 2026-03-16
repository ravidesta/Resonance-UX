/**
 * Resonance Vault — Bitstamp Hash / Timestamping Utility
 * Generates project hashes and anchors them to public timestamping services
 */

// Generate SHA-256 hash of project content
async function hashProject(files) {
  const encoder = new TextEncoder();
  const sortedFiles = [...files].sort((a, b) => a.path.localeCompare(b.path));
  const concatenated = sortedFiles.map(f => `${f.path}:${f.hash}`).join('\n');
  const data = encoder.encode(concatenated);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Generate a hash from a string
async function hashString(content) {
  const encoder = new TextEncoder();
  const data = encoder.encode(content);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Format a bitstamp entry for the calendar
function formatBitstampEntry(projectHash, source, txRef) {
  return {
    event_type: 'bitstamp',
    title: `Hash anchored: ${projectHash.substring(0, 12)}...`,
    notes: `Project hash: ${projectHash}\nTimestamp source: ${source}\nTransaction: ${txRef || 'pending'}`,
    bitstamp_hash: projectHash,
    bitstamp_source: source,
    bitstamp_tx: txRef || '',
    timestamp: new Date().toISOString(),
  };
}

// Known timestamping services
const TIMESTAMP_SERVICES = [
  {
    id: 'openbitstamp',
    name: 'OpenBitstamp.org',
    url: 'https://www.openbitstamp.org',
    description: 'Bitcoin-based proof-of-existence timestamping',
    type: 'blockchain',
  },
  {
    id: 'opentimestamps',
    name: 'OpenTimestamps',
    url: 'https://opentimestamps.org',
    description: 'Scalable, trustless Bitcoin timestamping',
    type: 'blockchain',
  },
  {
    id: 'originstamp',
    name: 'OriginStamp',
    url: 'https://originstamp.com',
    description: 'Multi-blockchain timestamping (Bitcoin, Ethereum)',
    type: 'blockchain',
  },
  {
    id: 'internal',
    name: 'Resonance Vault Internal',
    url: null,
    description: 'Local SHA-256 hash log with calendar entry',
    type: 'local',
  },
];

export { hashProject, hashString, formatBitstampEntry, TIMESTAMP_SERVICES };
