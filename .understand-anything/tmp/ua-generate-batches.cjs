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
  const candidates = [
    'lib/main.dart',
    'main.dart',
    'src/main.dart',
    'src/main.ts',
    'src/index.ts',
    'src/App.tsx',
    'index.js',
    'main.py',
    'app.py',
  ];
  return candidates.find((item) => fileSet.has(item)) || null;
}

function fileNodeType(file) {
  if (file.fileCategory === 'config') return 'config';
  if (file.fileCategory === 'docs') return 'document';
  if (file.fileCategory === 'markup') return 'file';
  if (file.fileCategory === 'script') return 'file';
  if (file.fileCategory === 'infra') {
    const p = file.path;
    if (p.startsWith('.github/workflows/') || p.startsWith('.circleci/') || p === '.gitlab-ci.yml') {
      return 'pipeline';
    }
    if (p.endsWith('.tf') || p.endsWith('.tfvars') || path.basename(p) === 'Vagrantfile') {
      return 'resource';
    }
    return 'service';
  }
  if (file.fileCategory === 'data') {
    if (file.path.endsWith('.sql')) return 'table';
    if (file.path.endsWith('.graphql') || file.path.endsWith('.gql') || file.path.endsWith('.proto') || file.path.endsWith('.prisma')) {
      return 'schema';
    }
    return 'schema';
  }
  return 'file';
}

function fileNodeId(file) {
  return `${fileNodeType(file)}:${file.path}`;
}

function complexityFromLines(lines) {
  if (lines > 200) return 'complex';
  if (lines >= 50) return 'moderate';
  return 'simple';
}

function summaryForFile(file, entryPoint) {
  const name = path.basename(file.path);
  if (file.path === entryPoint) return '应用入口文件，负责启动 Flutter 应用并连接主要页面或状态流程。';
  if (file.type === 'document') return `文档文件，说明 ${name} 相关的项目背景、使用方式或开发信息。`;
  if (file.type === 'config') return `配置文件，定义 ${name} 对构建、分析或运行行为的约束。`;
  if (file.type === 'pipeline') return `流水线配置文件，定义 ${name} 相关的自动化执行步骤。`;
  if (file.type === 'resource') return `基础设施描述文件，声明 ${name} 相关的资源或环境配置。`;
  if (file.type === 'service') return `服务或部署文件，描述 ${name} 对应用运行环境的组织方式。`;
  if (file.type === 'schema') return `数据或结构定义文件，约束 ${name} 提供的模式和字段组织。`;
  if (file.type === 'table') return `数据定义文件，记录 ${name} 相关的表结构或迁移内容。`;
  if (file.language === 'dart') return `Dart 源文件，承载 ${name} 对应的页面、组件、状态或业务辅助逻辑。`;
  if (file.path.startsWith('test/')) return `测试文件，用于验证 ${name} 所覆盖模块的行为与稳定性。`;
  return `项目文件，承担 ${name} 在当前代码库中的实现或支撑职责。`;
}

function tagsForFile(file, entryPoint) {
  const tags = new Set();
  if (file.path === entryPoint) tags.add('entry-point');
  if (file.path.startsWith('test/') || /\.test\.|\.spec\./.test(file.path)) tags.add('test');
  if (file.language === 'dart') tags.add('dart');
  if (file.path.startsWith('lib/')) tags.add('application');
  if (file.fileCategory === 'config') tags.add('configuration');
  if (file.fileCategory === 'docs') tags.add('documentation');
  if (file.fileCategory === 'infra') tags.add('infrastructure');
  if (file.fileCategory === 'data') tags.add('schema-definition');
  if (file.path.includes('/widget') || file.path.includes('/widgets/')) tags.add('component');
  if (file.path.includes('/page') || file.path.includes('/pages/')) tags.add('screen');
  if (file.path.includes('/service') || file.path.includes('/repository')) tags.add('service');
  if (file.path.includes('/controller') || file.path.includes('/logic')) tags.add('state-management');
  if (file.path === 'pubspec.yaml') tags.add('build-system');
  if (file.path === 'README.md') tags.add('overview');
  if (tags.size < 3) tags.add('project-file');
  if (tags.size < 4) tags.add('internal');
  if (tags.size < 5) tags.add(kebab(path.basename(file.path, path.extname(file.path))) || 'source');
  return [...tags].slice(0, 5);
}

function splitLines(content) {
  return content.split(/\r?\n/);
}

function findBlockEnd(lines, startIndex) {
  let depth = 0;
  let started = false;
  for (let i = startIndex; i < lines.length; i++) {
    const line = lines[i];
    for (const ch of line) {
      if (ch === '{') {
        depth++;
        started = true;
      } else if (ch === '}') {
        depth--;
        if (started && depth <= 0) return i + 1;
      }
    }
  }
  return Math.min(lines.length, startIndex + 20);
}

function extractDartSymbols(filePath) {
  let content = '';
  try {
    content = fs.readFileSync(path.join(root, filePath), 'utf8');
  } catch {
    return { functions: [], classes: [], exports: [] };
  }
  const lines = splitLines(content);
  const functions = [];
  const classes = [];
  const exports = [];

  const classRe = /^(?:abstract\s+)?class\s+([A-Za-z_]\w*)/;
  const functionRe = /^(?:[A-Za-z_<>\?\[\],\s]+)\s+([A-Za-z_]\w*)\s*\(([^)]*)\)\s*(?:async\s*)?\{/;

  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    if (raw.startsWith(' ') || raw.startsWith('\t')) continue;
    const line = raw.trim();
    const classMatch = line.match(classRe);
    if (classMatch) {
      const endLine = findBlockEnd(lines, i);
      const body = lines.slice(i, endLine).join('\n');
      const methodMatches = [...body.matchAll(/^\s{2,}(?:static\s+)?(?:[A-Za-z_<>\?\[\],\s]+)\s+([A-Za-z_]\w*)\s*\(/gm)];
      classes.push({
        name: classMatch[1],
        startLine: i + 1,
        endLine,
        methods: methodMatches.map((m) => m[1]),
        properties: [],
      });
      continue;
    }
    const fnMatch = line.match(functionRe);
    if (fnMatch) {
      const reserved = new Set(['if', 'for', 'while', 'switch', 'catch']);
      if (reserved.has(fnMatch[1])) continue;
      const endLine = findBlockEnd(lines, i);
      const params = fnMatch[2]
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean)
        .map((item) => item.split(/\s+/).pop());
      functions.push({
        name: fnMatch[1],
        startLine: i + 1,
        endLine,
        params,
      });
      if (fnMatch[1] === 'main') {
        exports.push({ name: 'main', line: i + 1, isDefault: false });
      }
    }
  }
  return { functions, classes, exports };
}

function functionSummary(name, filePath) {
  return `函数 ${name} 位于 ${path.basename(filePath)} 中，用于完成该文件承担的局部逻辑或流程拼装。`;
}

function classSummary(name, filePath) {
  return `类型 ${name} 位于 ${path.basename(filePath)} 中，封装该文件的核心结构、界面或状态职责。`;
}

function createFileNode(file, entryPoint) {
  const type = fileNodeType(file);
  return {
    id: `${type}:${file.path}`,
    type,
    name: path.basename(file.path),
    filePath: file.path,
    summary: summaryForFile({ ...file, type }, entryPoint),
    tags: tagsForFile(file, entryPoint),
    complexity: complexityFromLines(file.sizeLines || 0),
  };
}

function createFunctionNode(filePath, fn) {
  return {
    id: `function:${filePath}:${fn.name}`,
    type: 'function',
    name: fn.name,
    filePath,
    lineRange: [fn.startLine, fn.endLine],
    summary: functionSummary(fn.name, filePath),
    tags: ['function', 'internal-logic', 'code-structure'],
    complexity: complexityFromLines((fn.endLine || fn.startLine) - fn.startLine + 1),
  };
}

function createClassNode(filePath, cls) {
  return {
    id: `class:${filePath}:${cls.name}`,
    type: 'class',
    name: cls.name,
    filePath,
    lineRange: [cls.startLine, cls.endLine],
    summary: classSummary(cls.name, filePath),
    tags: ['class', 'code-structure', 'internal-type'],
    complexity: complexityFromLines((cls.endLine || cls.startLine) - cls.startLine + 1),
  };
}

function addEdge(edges, source, target, type, weight) {
  if (!source || !target || source === target) return;
  edges.push({ source, target, type, direction: 'forward', weight });
}

function relevantMainTargets(fileSet, entryPoint) {
  const targets = [];
  if (entryPoint && fileSet.has(entryPoint)) targets.push(entryPoint);
  for (const candidate of ['lib/app.dart', 'lib/router.dart', 'lib/home.dart']) {
    if (fileSet.has(candidate)) targets.push(candidate);
  }
  return [...new Set(targets)];
}

function writeBatchParts(batchIndex, files, nodes, edges, neighborMap, batchImportData) {
  const fileOrder = [...files].sort((a, b) => a.path.localeCompare(b.path));
  const nodeMap = new Map(nodes.map((node) => [node.id, node]));
  const nodeFilePath = new Map();
  for (const node of nodes) {
    const fp = node.filePath || '';
    if (!nodeFilePath.has(fp)) nodeFilePath.set(fp, []);
    nodeFilePath.get(fp).push(node.id);
  }

  const nodeCount = nodes.length;
  const edgeCount = edges.length;
  const parts = (nodeCount <= 60 && edgeCount <= 120) ? 1 : Math.ceil(Math.max(nodeCount / 60, edgeCount / 120));
  const chunkSize = Math.ceil(fileOrder.length / parts);

  for (let part = 0; part < parts; part++) {
    const slice = fileOrder.slice(part * chunkSize, (part + 1) * chunkSize);
    const slicePaths = new Set(slice.map((file) => file.path));
    const partNodeIds = new Set();
    for (const file of slice) {
      const ids = nodeFilePath.get(file.path) || [];
      for (const id of ids) partNodeIds.add(id);
    }
    const partNodes = [...partNodeIds].map((id) => nodeMap.get(id)).filter(Boolean);
    const partEdges = edges.filter((edge) => partNodeIds.has(edge.source));

    for (const edge of partEdges) {
      const targetKnown = partNodeIds.has(edge.target)
        || /^file:/.test(edge.target)
        || /^function:/.test(edge.target)
        || /^class:/.test(edge.target);
      if (!targetKnown) {
        throw new Error(`Invalid edge in batch ${batchIndex} part ${part + 1}: ${edge.source} -> ${edge.target}`);
      }
    }

    const suffix = parts === 1 ? '' : `-part-${part + 1}`;
    writeJson(path.join(intermediateDir, `batch-${batchIndex}${suffix}.json`), {
      nodes: partNodes,
      edges: partEdges,
    });
  }

  return parts;
}

function main() {
  const scan = readJson(path.join(intermediateDir, 'scan-result.json'));
  const batches = readJson(path.join(intermediateDir, 'batches.json'));
  const filesByPath = new Map((scan.files || []).map((file) => [file.path, file]));
  const fileSet = new Set((scan.files || []).map((file) => file.path));
  const entryPoint = detectEntryPoint(fileSet);
  const mainTargets = relevantMainTargets(fileSet, entryPoint);
  const results = [];

  for (const batch of batches.batches || []) {
    const batchIndex = batch.batchIndex;
    const inputPath = path.join(tmpDir, `ua-file-analyzer-input-${batchIndex}.json`);
    const outputPath = path.join(tmpDir, `ua-file-extract-results-${batchIndex}.json`);
    writeJson(inputPath, {
      projectRoot: root.replace(/\\/g, '/'),
      batchFiles: batch.files,
      batchImportData: batch.batchImportData || {},
    });

    const extract = spawnSync('node', [path.join(pluginSkillDir, 'extract-structure.mjs'), inputPath, outputPath], {
      cwd: root,
      encoding: 'utf8',
      maxBuffer: 10 * 1024 * 1024,
    });
    if (extract.status !== 0) {
      throw new Error(`extract-structure failed for batch ${batchIndex}: ${extract.stderr || extract.stdout}`);
    }

    const extracted = readJson(outputPath);
    const extractedByPath = new Map((extracted.results || []).map((item) => [item.path, item]));
    const nodes = [];
    const edges = [];

    for (const file of batch.files) {
      const normalized = filesByPath.get(file.path) || file;
      const fileNode = createFileNode(normalized, entryPoint);
      nodes.push(fileNode);

      const item = extractedByPath.get(file.path) || { path: file.path, functions: [], classes: [], exports: [], callGraph: [], metrics: {} };
      let functions = item.functions || [];
      let classes = item.classes || [];
      let exportsList = item.exports || [];

      if (normalized.language === 'dart' && functions.length === 0 && classes.length === 0) {
        const supplemental = extractDartSymbols(file.path);
        functions = supplemental.functions;
        classes = supplemental.classes;
        exportsList = supplemental.exports;
      }

      const exportedNames = new Set((exportsList || []).map((entry) => entry.name));
      for (const fn of functions) {
        const lines = (fn.endLine || fn.startLine) - fn.startLine + 1;
        if (lines < 10 && !exportedNames.has(fn.name)) continue;
        const fnNode = createFunctionNode(file.path, fn);
        nodes.push(fnNode);
        addEdge(edges, fileNode.id, fnNode.id, 'contains', 1.0);
        if (exportedNames.has(fn.name)) addEdge(edges, fileNode.id, fnNode.id, 'exports', 0.8);
      }

      for (const cls of classes) {
        const lines = (cls.endLine || cls.startLine) - cls.startLine + 1;
        const methodCount = Array.isArray(cls.methods) ? cls.methods.length : 0;
        if (lines < 20 && methodCount < 2 && !exportedNames.has(cls.name)) continue;
        const clsNode = createClassNode(file.path, cls);
        nodes.push(clsNode);
        addEdge(edges, fileNode.id, clsNode.id, 'contains', 1.0);
        if (exportedNames.has(cls.name)) addEdge(edges, fileNode.id, clsNode.id, 'exports', 0.8);
      }

      for (const target of batch.batchImportData[file.path] || []) {
        addEdge(edges, fileNode.id, `file:${target}`, 'imports', 0.7);
      }

      if (fileNode.type === 'config') {
        for (const target of mainTargets) {
          addEdge(edges, fileNode.id, `file:${target}`, 'configures', 0.6);
        }
      }
      if (fileNode.type === 'document') {
        for (const target of mainTargets) {
          addEdge(edges, fileNode.id, `file:${target}`, 'documents', 0.5);
        }
      }
      if (fileNode.type === 'service') {
        for (const target of mainTargets) {
          addEdge(edges, fileNode.id, `file:${target}`, 'deploys', 0.7);
        }
      }
      if (file.path.startsWith('test/')) {
        const guessed = file.path.replace(/^test\//, 'lib/').replace(/_test\.dart$/, '.dart');
        if (fileSet.has(guessed)) {
          addEdge(edges, `file:${guessed}`, fileNode.id, 'tested_by', 0.5);
        }
      }
    }

    const dedupNodes = [];
    const seenNodes = new Set();
    for (const node of nodes) {
      if (seenNodes.has(node.id)) continue;
      seenNodes.add(node.id);
      dedupNodes.push(node);
    }

    const dedupEdges = [];
    const seenEdges = new Set();
    for (const edge of edges) {
      const key = `${edge.source}|${edge.target}|${edge.type}|${edge.direction}`;
      if (seenEdges.has(key)) continue;
      seenEdges.add(key);
      dedupEdges.push(edge);
    }

    const parts = writeBatchParts(batchIndex, batch.files, dedupNodes, dedupEdges, batch.neighborMap || {}, batch.batchImportData || {});
    results.push({ batchIndex, parts, nodes: dedupNodes.length, edges: dedupEdges.length });
  }

  console.log(JSON.stringify({ entryPoint, batches: results }, null, 2));
}

main();
