const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const root = process.cwd();
const uaDir = path.join(root, '.understand-anything');
const intermediateDir = path.join(uaDir, 'intermediate');
const tmpDir = path.join(uaDir, 'tmp');
const pluginSkillDir = 'C:\\Users\\Administrator\\.understand-anything\\repo\\understand-anything-plugin\\skills\\understand';

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, JSON.stringify(value, null, 2));
}

function kebab(value) {
  return String(value)
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();
}

function detectEntryPoint(fileSet) {
  const candidates = ['lib/main.dart', 'main.dart', 'src/main.ts', 'src/index.ts', 'src/App.tsx'];
  return candidates.find((item) => fileSet.has(item)) || null;
}

function mergeBatches(scan) {
  const files = fs.readdirSync(intermediateDir)
    .filter((name) => /^batch-\d+(?:-part-\d+)?\.json$/.test(name))
    .sort((a, b) => a.localeCompare(b, undefined, { numeric: true }));
  const nodesById = new Map();
  const edgeKeys = new Set();
  const edges = [];

  for (const file of files) {
    const data = readJson(path.join(intermediateDir, file));
    for (const node of data.nodes || []) {
      nodesById.set(node.id, node);
    }
    for (const edge of data.edges || []) {
      const key = `${edge.source}|${edge.target}|${edge.type}|${edge.direction || 'forward'}`;
      if (edgeKeys.has(key)) continue;
      edgeKeys.add(key);
      edges.push({
        source: edge.source,
        target: edge.target,
        type: edge.type,
        direction: edge.direction || 'forward',
        weight: edge.weight ?? 0.5,
      });
    }
  }

  const fileNodeIds = new Set([...nodesById.values()].filter((node) => (
    ['file', 'config', 'document', 'service', 'pipeline', 'table', 'schema', 'resource', 'endpoint'].includes(node.type)
  )).map((node) => node.id));

  for (const [srcPath, targets] of Object.entries(scan.importMap || {})) {
    const srcId = `file:${srcPath}`;
    if (!fileNodeIds.has(srcId)) continue;
    for (const target of targets || []) {
      const targetId = `file:${target}`;
      if (!fileNodeIds.has(targetId) || targetId === srcId) continue;
      const key = `${srcId}|${targetId}|imports|forward`;
      if (edgeKeys.has(key)) continue;
      edgeKeys.add(key);
      edges.push({
        source: srcId,
        target: targetId,
        type: 'imports',
        direction: 'forward',
        weight: 0.7,
        recoveredFromImportMap: true,
      });
    }
  }

  const validNodeIds = new Set(nodesById.keys());
  const validEdges = edges.filter((edge) => validNodeIds.has(edge.source) && validNodeIds.has(edge.target) && edge.source !== edge.target);
  return { nodes: [...nodesById.values()], edges: validEdges };
}

function layerNameForNode(node) {
  const filePath = node.filePath || '';
  if (node.type === 'document' || node.type === 'config' || filePath.startsWith('.understand-anything/')) return 'Project Docs & Config';
  if (/^(android|ios|linux|macos|web|windows)\//.test(filePath)) return 'Platform Integration';
  if (filePath.startsWith('test/')) return 'Verification';
  if (filePath.startsWith('assets/')) return 'Assets';
  if (filePath === 'lib/main.dart' || filePath.startsWith('lib/app') || filePath.startsWith('lib/router')) return 'Application Entry';
  if (filePath.startsWith('lib/')) return 'Flutter Features';
  return 'Project Docs & Config';
}

function buildLayers(nodes) {
  const fileLevel = nodes.filter((node) => ['file', 'config', 'document', 'service', 'pipeline', 'table', 'schema', 'resource', 'endpoint'].includes(node.type));
  const groups = new Map();
  for (const node of fileLevel) {
    const name = layerNameForNode(node);
    if (!groups.has(name)) groups.set(name, []);
    groups.get(name).push(node.id);
  }
  const descriptions = {
    'Project Docs & Config': '项目说明、分析配置与构建元数据所在层。',
    'Platform Integration': 'Android、iOS、桌面与 Web 平台壳层及原生集成文件。',
    'Verification': '测试与验证文件所在层。',
    'Assets': '静态资源、动画与媒体素材所在层。',
    'Application Entry': '应用启动入口以及整体装配相关文件。',
    'Flutter Features': 'Flutter 页面、组件、功能模块与业务实现文件。',
  };
  return [...groups.entries()].map(([name, nodeIds]) => ({
    id: `layer:${kebab(name)}`,
    name,
    description: descriptions[name] || `${name} 相关文件层。`,
    nodeIds: nodeIds.sort(),
  }));
}

function buildTour(nodes, entryPoint) {
  const fileNodeIds = new Set(nodes.map((node) => node.id));
  const steps = [];
  const step1 = ['document:README.md', 'config:pubspec.yaml'].filter((id) => fileNodeIds.has(id));
  if (step1.length) {
    steps.push({
      order: 1,
      title: '项目概览',
      description: '先阅读 README 与 pubspec，快速了解这个 Flutter 项目的定位、依赖与基础运行方式。',
      nodeIds: step1,
    });
  }
  if (entryPoint && fileNodeIds.has(`file:${entryPoint}`)) {
    steps.push({
      order: steps.length + 1,
      title: '应用入口',
      description: '从主入口文件开始，观察应用如何启动并连接到后续页面与状态流。',
      nodeIds: [`file:${entryPoint}`],
    });
  }
  const libFiles = nodes
    .filter((node) => node.type === 'file' && node.filePath && node.filePath.startsWith('lib/'))
    .slice(0, 6)
    .map((node) => node.id);
  if (libFiles.length) {
    steps.push({
      order: steps.length + 1,
      title: '核心功能层',
      description: '浏览 lib 目录下的核心文件，理解页面组织、组件拆分与业务功能分布。',
      nodeIds: libFiles,
    });
  }
  const platformFiles = nodes
    .filter((node) => node.filePath && /^(android|ios|linux|macos|web|windows)\//.test(node.filePath))
    .slice(0, 4)
    .map((node) => node.id);
  if (platformFiles.length) {
    steps.push({
      order: steps.length + 1,
      title: '平台集成',
      description: '最后查看各平台工程文件，确认 Flutter 应用在不同宿主平台上的接入方式。',
      nodeIds: platformFiles,
    });
  }
  return steps;
}

function validate(graph) {
  const issues = [];
  const warnings = [];
  if (!Array.isArray(graph.nodes)) issues.push('graph.nodes is missing or not an array');
  if (!Array.isArray(graph.edges)) issues.push('graph.edges is missing or not an array');
  const nodeIds = new Set();
  const fileLevelTypes = new Set(['file', 'config', 'document', 'service', 'pipeline', 'table', 'schema', 'resource', 'endpoint']);
  for (let i = 0; i < graph.nodes.length; i++) {
    const node = graph.nodes[i];
    if (!node.id) issues.push(`Node[${i}] missing id`);
    if (!node.type) issues.push(`Node[${i}] missing type`);
    if (!node.name) issues.push(`Node[${i}] missing name`);
    if (!node.summary) issues.push(`Node[${i}] missing summary`);
    if (!Array.isArray(node.tags) || !node.tags.length) issues.push(`Node[${i}] missing tags`);
    if (node.id) nodeIds.add(node.id);
  }
  for (let i = 0; i < graph.edges.length; i++) {
    const edge = graph.edges[i];
    if (!nodeIds.has(edge.source)) issues.push(`Edge[${i}] source '${edge.source}' not found`);
    if (!nodeIds.has(edge.target)) issues.push(`Edge[${i}] target '${edge.target}' not found`);
  }
  const assigned = new Set();
  for (const layer of graph.layers || []) {
    for (const id of layer.nodeIds || []) {
      if (!nodeIds.has(id)) issues.push(`Layer '${layer.id}' refs missing node '${id}'`);
      assigned.add(id);
    }
  }
  for (const node of graph.nodes) {
    if (fileLevelTypes.has(node.type) && !assigned.has(node.id)) issues.push(`File node '${node.id}' not in any layer`);
  }
  const connected = new Set(graph.edges.flatMap((edge) => [edge.source, edge.target]));
  for (const node of graph.nodes) {
    if (!connected.has(node.id)) warnings.push(`Node '${node.id}' has no edges (orphan)`);
  }
  return {
    issues,
    warnings,
    stats: {
      totalNodes: graph.nodes.length,
      totalEdges: graph.edges.length,
      totalLayers: (graph.layers || []).length,
      tourSteps: (graph.tour || []).length,
    },
  };
}

function main() {
  const scan = readJson(path.join(intermediateDir, 'scan-result.json'));
  const commit = spawnSync('git', ['rev-parse', 'HEAD'], { cwd: root, encoding: 'utf8' }).stdout.trim();
  const fileSet = new Set((scan.files || []).map((file) => file.path));
  const entryPoint = detectEntryPoint(fileSet);
  const assembled = mergeBatches(scan);
  writeJson(path.join(intermediateDir, 'assembled-graph.json'), assembled);

  const layers = buildLayers(assembled.nodes);
  const tour = buildTour(assembled.nodes, entryPoint);

  const graph = {
    version: '1.0.0',
    project: {
      name: scan.projectName || 'infibo_app',
      languages: scan.languages || ['dart', 'yaml'],
      frameworks: scan.frameworks || ['flutter'],
      description: scan.projectDescription || 'Flutter mobile application project',
      analyzedAt: new Date().toISOString(),
      gitCommitHash: commit,
    },
    nodes: assembled.nodes,
    edges: assembled.edges,
    layers,
    tour,
  };

  const review = validate(graph);
  writeJson(path.join(intermediateDir, 'review.json'), review);
  writeJson(path.join(uaDir, 'knowledge-graph.json'), graph);

  const sourceFilePaths = (scan.files || [])
    .filter((file) => ['code', 'script', 'markup'].includes(file.fileCategory))
    .map((file) => file.path);
  writeJson(path.join(intermediateDir, 'fingerprint-input.json'), {
    projectRoot: root.replace(/\\/g, '/'),
    sourceFilePaths,
    gitCommitHash: commit,
  });

  const fp = spawnSync('node', [path.join(pluginSkillDir, 'build-fingerprints.mjs'), path.join(intermediateDir, 'fingerprint-input.json')], {
    cwd: root,
    encoding: 'utf8',
    maxBuffer: 10 * 1024 * 1024,
  });
  if (fp.status !== 0 || !/Fingerprints baseline:/i.test(`${fp.stdout}\n${fp.stderr}`)) {
    throw new Error(`Fingerprint baseline failed:\n${fp.stdout}\n${fp.stderr}`);
  }

  writeJson(path.join(uaDir, 'meta.json'), {
    lastAnalyzedAt: new Date().toISOString(),
    gitCommitHash: commit,
    version: '1.0.0',
    analyzedFiles: (scan.files || []).length,
  });

  console.log(JSON.stringify({
    entryPoint,
    nodes: graph.nodes.length,
    edges: graph.edges.length,
    layers: graph.layers.map((layer) => layer.name),
    tourSteps: graph.tour.length,
    review,
  }, null, 2));
}

main();
