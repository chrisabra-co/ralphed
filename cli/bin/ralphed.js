#!/usr/bin/env node

const prompts = require('prompts');
const pc = require('picocolors');
const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');

const BANNER = `
 ██████╗  █████╗ ██╗     ██████╗ ██╗  ██╗███████╗██████╗
 ██╔══██╗██╔══██╗██║     ██╔══██╗██║  ██║██╔════╝██╔══██╗
 ██████╔╝███████║██║     ██████╔╝███████║█████╗  ██║  ██║
 ██╔══██╗██╔══██║██║     ██╔═══╝ ██╔══██║██╔══╝  ██║  ██║
 ██║  ██║██║  ██║███████╗██║     ██║  ██║███████╗██████╔╝
 ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝
`;

const TEMPLATES_DIR = path.join(__dirname, '..', 'templates');

async function main() {
  console.log(pc.yellow(BANNER));
  console.log(pc.dim('  Autonomous AI agent workflow for Claude Code\n'));

  // Check if claude CLI is available
  let claudeAvailable = false;
  try {
    execSync('which claude', { stdio: 'ignore' });
    claudeAvailable = true;
  } catch {
    // Claude CLI not found
  }

  const response = await prompts([
    {
      type: 'text',
      name: 'directory',
      message: 'Project directory',
      initial: './plans',
      validate: (value) => value.length > 0 || 'Directory is required'
    },
    {
      type: 'text',
      name: 'prdPath',
      message: 'Path to PRD file or folder (optional)',
      initial: ''
    },
    {
      type: claudeAvailable ? 'confirm' : null,
      name: 'autoGenerate',
      message: 'Auto-generate features from PRD using Claude Code?',
      initial: true,
      active: 'yes',
      inactive: 'no'
    }
  ], {
    onCancel: () => {
      console.log(pc.red('\nSetup cancelled.'));
      process.exit(1);
    }
  });

  const targetDir = path.resolve(response.directory);

  console.log('');
  console.log(pc.cyan('Setting up RALPHED...'));
  console.log('');

  // Create directory if it doesn't exist
  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
    console.log(pc.green('✓') + ` Created ${pc.dim(targetDir)}`);
  }

  // Create logs directory
  const logsDir = path.join(targetDir, 'logs');
  if (!fs.existsSync(logsDir)) {
    fs.mkdirSync(logsDir, { recursive: true });
  }
  fs.writeFileSync(path.join(logsDir, '.gitkeep'), '');
  console.log(pc.green('✓') + ` Created ${pc.dim('logs/')}`);

  // Copy template files (source -> destination mapping for renamed files)
  const templateFiles = [
    { src: 'ralphed.sh', dest: 'ralphed.sh' },
    { src: 'gitignore', dest: '.gitignore' },  // Renamed for npm publishing
    { src: 'AGENTS.md', dest: 'AGENTS.md' },
    { src: 'IMPLEMENTATION_PLAN.md', dest: 'IMPLEMENTATION_PLAN.md' },
    { src: 'PROMPT_plan.md', dest: 'PROMPT_plan.md' },
    { src: 'PROMPT_build.md', dest: 'PROMPT_build.md' }
  ];

  for (const file of templateFiles) {
    const src = path.join(TEMPLATES_DIR, file.src);
    const dest = path.join(targetDir, file.dest);

    if (fs.existsSync(src)) {
      fs.copyFileSync(src, dest);

      // Make shell script executable
      if (file.dest.endsWith('.sh')) {
        fs.chmodSync(dest, '755');
      }

      console.log(pc.green('✓') + ` Created ${pc.dim(file.dest)}`);
    }
  }

  // Handle PRD (can be a file or folder)
  let prdExists = false;
  let prdIsDirectory = false;
  if (response.prdPath && fs.existsSync(response.prdPath)) {
    prdExists = true;
    prdIsDirectory = fs.statSync(response.prdPath).isDirectory();

    if (prdIsDirectory) {
      console.log(pc.green('✓') + ` Using PRD folder: ${pc.dim(response.prdPath)}`);
    } else {
      // Single file - copy it
      const prdDest = path.join(targetDir, 'PRD.md');
      fs.copyFileSync(response.prdPath, prdDest);
      console.log(pc.green('✓') + ` Copied PRD to ${pc.dim('PRD.md')}`);
    }
  } else if (!response.prdPath) {
    // Copy template PRD
    const templatePrd = path.join(TEMPLATES_DIR, 'PRD.md');
    if (fs.existsSync(templatePrd)) {
      fs.copyFileSync(templatePrd, path.join(targetDir, 'PRD.md'));
      console.log(pc.green('✓') + ` Created ${pc.dim('PRD.md')} (template)`);
    }
  }

  // Auto-generate features from PRD (file or folder)
  if (response.autoGenerate && prdExists) {
    console.log('');
    console.log(pc.cyan('Generating features from PRD...'));
    console.log(pc.dim('This will run Claude Code to parse your PRD.\n'));

    const planPath = path.join(targetDir, 'IMPLEMENTATION_PLAN.md');

    const prdReference = prdIsDirectory ? `@${response.prdPath}/` : `@${response.prdPath}`;
    const parseInstruction = prdIsDirectory
      ? 'Parse all documents in this folder'
      : 'Parse this PRD/project outline';

    const claudePrompt = `${prdReference}

${parseInstruction} and generate an IMPLEMENTATION_PLAN.md file.

Output a Markdown file with this structure:

# Project Name from PRD

Brief description from PRD.

---

## category-name

### Feature description
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

### Another feature in same category
- [ ] Step 1
- [ ] Step 2

---

## another-category [OPUS]

### Complex feature requiring advanced reasoning
- [ ] Step 1
- [ ] Step 2

---

## Discovered Issues

<!-- Issues found during implementation -->

## Notes

<!-- Implementation decisions -->

Guidelines:
- Break down the PRD into small, atomic features
- Each feature (heading + checkboxes) should be completable in one iteration
- Order features by dependency (foundational first)
- Categories: setup, database, auth, api, ui, feature, testing, etc.
- Steps (checkboxes) should be acceptance criteria
- All tasks start unchecked: - [ ]

IMPORTANT - Topic Scope Test:
Each feature MUST pass this test: describable in one sentence WITHOUT conjunctions (and, or, but).
- GOOD: "The color extraction system analyzes images to identify dominant colors"
- BAD: "Handle authentication, profiles, and billing" (split into 3 features!)
If a feature has multiple concerns, split it into separate features.

[OPUS] tag guidance:
- Add [OPUS] tag after category name ONLY for complex features:
  * Complex auth flows (OAuth, multi-provider, session edge cases)
  * Intricate state management or data flow logic
  * Features with many edge cases or cross-cutting concerns
  * Architectural decisions affecting multiple parts of the codebase
- Most categories should NOT have the [OPUS] tag (defaults to sonnet)

Write the output directly to: ${planPath}`;

    try {
      const claude = spawn('claude', ['--permission-mode', 'acceptEdits', '-p', claudePrompt], {
        stdio: 'inherit',
        cwd: targetDir
      });

      await new Promise((resolve, reject) => {
        claude.on('close', (code) => {
          if (code === 0) {
            console.log('');
            console.log(pc.green('✓') + ' Features generated from PRD');
            resolve();
          } else {
            console.log(pc.yellow('⚠') + ' Feature generation completed with warnings');
            resolve();
          }
        });
        claude.on('error', reject);
      });
    } catch (error) {
      console.log(pc.yellow('⚠') + ` Could not auto-generate features: ${error.message}`);
      console.log(pc.dim('  You can manually edit IMPLEMENTATION_PLAN.md'));
    }
  }

  // Print next steps
  console.log('');
  console.log(pc.green('Done!') + ' RALPHED is ready.\n');
  console.log(pc.bold('Next steps:\n'));

  const steps = [
    response.prdPath ? null : `Edit ${pc.cyan('PRD.md')} with your project requirements`,
    response.autoGenerate && prdExists ? null : `Edit ${pc.cyan('IMPLEMENTATION_PLAN.md')} with your features`,
    `Run ${pc.cyan('/sandbox')} in Claude Code to enable bash auto-allow`,
    `Run planning first: ${pc.cyan(`cd ${response.directory} && ./ralphed.sh --mode plan 1`)}`,
    `Start building: ${pc.cyan('./ralphed.sh 10')}`
  ].filter(Boolean);

  steps.forEach((step, i) => {
    console.log(`  ${pc.dim(`${i + 1}.`)} ${step}`);
  });

  console.log('');
  console.log(pc.bold('Key files:'));
  console.log(pc.dim('  AGENTS.md              - Operational guide (add project conventions here)'));
  console.log(pc.dim('  IMPLEMENTATION_PLAN.md - Task tracking (updated each iteration)'));
  console.log(pc.dim('  PROMPT_plan.md         - Planning mode instructions'));
  console.log(pc.dim('  PROMPT_build.md        - Building mode instructions'));
  console.log('');
  console.log(pc.dim('Models: Uses Sonnet by default, auto-falls back to Opus when needed.'));
  console.log(pc.dim('        Add [OPUS] tag to complex feature categories, or let Claude self-escalate.'));
  console.log('');
  console.log(pc.dim('Learn more: https://github.com/chrisabra-co/ralphed'));
  console.log(pc.dim('Methodology: https://github.com/ghuntley/how-to-ralph-wiggum'));
  console.log('');
}

main().catch((err) => {
  console.error(pc.red('Error:'), err.message);
  process.exit(1);
});
