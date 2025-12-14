#!/usr/bin/env node

const { Command } = require('commander');
const chalk = require('chalk');
const inquirer = require('inquirer');
const ora = require('ora');
const figlet = require('figlet');
const gradient = require('gradient-string');
const chalkAnimation = require('chalk-animation');

const program = new Command();

// Ghost ASCII art variations
const ghosts = {
  classic: `
     .-.
    (o.o)
     |=|
    __|__
   //.=|=.\\\\
  // .=|=. \\\\
  \\\\ .=|=. //
   \\\\(_=_)//
    (:| |:)
     || ||
     () ()
     || ||
     || ||
    ==' '==`,

  cute: `
      .--.
     |o_o |
     |:_/ |
    //   \\ \\
   (|     | )
  /'\_   _/\`\\
  \___)=(___/`,

  spooky: `
         ___
       _/   \\_
      / \\ _ / \\
      \\  (_)  /
       |     |
      _|     |_
     /  \\ _ /  \\
     |   \\_/   |
      \\_______/
        |   |
        |   |`,

  tiny: `
   .-.
  (o.o)
   > ^`,

  king: `
      ___
     {___}
     (O.O)
      \\=/
    __|"|__
   /   =   \\
   |  ___  |
    \\_____/`
};

// Spooky fortunes
const fortunes = [
  "A mysterious presence watches over your code tonight... 👁️",
  "Beware of bugs that lurk in the shadows of your semicolons...",
  "Your next commit will haunt the repository forever... choose wisely.",
  "Three merge conflicts shall appear before the moon is full.",
  "The spirit of a forgotten TODO comment calls out to you...",
  "Your code will compile on the first try... said no ghost ever.",
  "A phantom variable hovers nearby, undefined and restless.",
  "The ancient curse of 'works on my machine' shall be lifted... eventually.",
  "Your test coverage pleases the spectral code reviewers.",
  "Beware: a wild null pointer approaches at midnight.",
  "The ghost of technical debt past shall visit you soon.",
  "Your documentation is so sparse, even ghosts can't find it.",
  "A recursive function haunts the call stack... forever...",
  "The spirits suggest you... have you tried turning it off and on again?",
  "Your pull request has been approved by the Council of Ethereal Developers."
];

// Ghost stories
const stories = [
  {
    title: "The Infinite Loop",
    content: `Long ago, a developer wrote a while loop without a break condition.
They say on quiet nights, you can still hear the CPU fan spinning...
The program runs to this day, in a server room no one dares to enter.
Some say the developer is still there, waiting for the loop to end...

But it never does. It. Never. Does. 👻`
  },
  {
    title: "The Missing Semicolon",
    content: `In the depths of a legacy codebase, there lived a bug.
Not just any bug - a bug that appeared only in production.
Developers searched for years, but found nothing in their tests.
One night, a junior dev stayed late, and finally saw it...

A single missing semicolon, hiding in plain sight.
But when they went to fix it... the line had vanished.
To this day, the bug still haunts production. 🌙`
  },
  {
    title: "The Haunted Repository",
    content: `They say never to clone the cursed repository.
But the new intern didn't believe in superstitions.
'git clone' they typed, confident and unafraid.

The download began: 1GB... 10GB... 100GB of node_modules.
It never stopped. The hard drive filled completely.
When they looked at their terminal, a message appeared:

'npm install is now haunting your dreams... forever.' 💀`
  },
  {
    title: "The Phantom Programmer",
    content: `In every codebase, there are commits from [deleted user].
No one knows who they were, or where they went.
But their code remains, undocumented and mysterious.

Legend says if you run 'git blame' at 3 AM,
You'll see commits from tomorrow, written by no one,
Fixing bugs that haven't happened yet. ⏰`
  }
];

// Haunting messages
const hauntingMessages = [
  "BOO! Did I scare you? 👻",
  "Debugging at this hour? How... spooky! 🕯️",
  "I see dead code... it's everywhere! 💀",
  "Your console.logs can't save you now! 🔮",
  "Commit your changes... before they disappear! ⚰️",
  "I've been watching your git history... interesting choices. 📜",
  "The spirits sense... a memory leak! 🌙",
  "Wooooooo! Stack overflow! Wooooooo! 👁️",
  "Your code compiles... but at what cost? 🦇",
  "I bring news from the realm of production errors! ⚡"
];

// Sleep function for dramatic effect
const sleep = (ms = 1000) => new Promise(resolve => setTimeout(resolve, ms));

// Animated title
async function showTitle() {
  console.clear();
  const title = figlet.textSync('BOOCLI', {
    font: 'Ghost',
    horizontalLayout: 'default'
  });
  const rainbowTitle = chalkAnimation.rainbow(title);
  await sleep(2000);
  rainbowTitle.stop();
  console.log(gradient.pastel.multiline(title));
  console.log(chalk.gray('                          A Spooky Terminal Companion\n'));
}

// Random ghost selector
function getRandomGhost() {
  const ghostTypes = Object.keys(ghosts);
  const randomType = ghostTypes[Math.floor(Math.random() * ghostTypes.length)];
  return { type: randomType, art: ghosts[randomType] };
}

// Haunt command
async function haunt() {
  await showTitle();

  const ghost = getRandomGhost();
  const message = hauntingMessages[Math.floor(Math.random() * hauntingMessages.length)];

  console.log(chalk.cyan(ghost.art));
  console.log('');

  const glitchText = chalkAnimation.karaoke(chalk.white.bold(message));
  await sleep(3000);
  glitchText.stop();

  console.log(chalk.white.bold(message));
  console.log('');
}

// Fortune command
async function tellFortune() {
  await showTitle();

  console.log(chalk.magenta(ghosts.king));
  console.log('');
  console.log(chalk.yellow.bold('🔮 The Ghost King peers into your future... 🔮\n'));

  const spinner = ora({
    text: chalk.gray('Consulting the spirits...'),
    spinner: 'dots12'
  }).start();

  await sleep(2000);
  spinner.stop();

  const fortune = fortunes[Math.floor(Math.random() * fortunes.length)];
  const glitch = chalkAnimation.pulse(chalk.yellow.bold(`\n${fortune}\n`));

  await sleep(3000);
  glitch.stop();
  console.log(chalk.yellow.bold(`\n${fortune}\n`));
}

// Story command
async function tellStory() {
  await showTitle();

  const story = stories[Math.floor(Math.random() * stories.length)];

  console.log(chalk.red(ghosts.spooky));
  console.log('');
  console.log(chalk.red.bold(`📖 ${story.title} 📖\n`));

  const spinner = ora({
    text: chalk.gray('The ghost begins to speak...'),
    spinner: 'bouncingBar'
  }).start();

  await sleep(2000);
  spinner.stop();

  console.log('');
  const lines = story.content.split('\n');
  for (const line of lines) {
    console.log(chalk.white(line));
    await sleep(500);
  }
  console.log('');
}

// Summon command - interactive
async function summon() {
  await showTitle();

  console.log(chalk.cyan(ghosts.cute));
  console.log('');
  console.log(chalk.cyan.bold('A friendly ghost appears! 👻\n'));

  const answers = await inquirer.prompt([
    {
      type: 'list',
      name: 'action',
      message: 'What would you like the ghost to do?',
      choices: [
        '🔮 Tell my fortune',
        '📖 Tell me a spooky story',
        '😱 Haunt my terminal',
        '🎲 Surprise me!',
        '👋 Say goodbye'
      ]
    }
  ]);

  switch (answers.action) {
    case '🔮 Tell my fortune':
      await tellFortune();
      break;
    case '📖 Tell me a spooky story':
      await tellStory();
      break;
    case '😱 Haunt my terminal':
      await haunt();
      break;
    case '🎲 Surprise me!':
      const surprises = [tellFortune, tellStory, haunt];
      await surprises[Math.floor(Math.random() * surprises.length)]();
      break;
    case '👋 Say goodbye':
      console.log('\n' + chalk.gray(ghosts.tiny));
      console.log(chalk.gray('\nThe ghost fades away... until next time... 👻\n'));
      return;
  }

  // Ask if they want to do something else
  const again = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'continue',
      message: 'Would you like to summon the ghost again?',
      default: true
    }
  ]);

  if (again.continue) {
    await summon();
  } else {
    console.log('\n' + chalk.gray(ghosts.tiny));
    console.log(chalk.gray('\nThe ghost fades away... until next time... 👻\n'));
  }
}

// ASCII graveyard
function showGraveyard() {
  console.clear();
  console.log('');
  console.log(chalk.gray('                                            /\\'));
  console.log(chalk.gray('                                           |  |'));
  console.log(chalk.gray('                                          /    \\'));
  console.log(chalk.gray('                                         |      |'));
  console.log(chalk.white('    ___                        ___         ') + chalk.gray('|      |') + chalk.white('        ___'));
  console.log(chalk.white('   /   \\      R.I.P.          /   \\        ') + chalk.gray(' \\    /') + chalk.white('        /   \\'));
  console.log(chalk.white('  | RIP |   NETSCAPE         | IE  |        ') + chalk.gray('\\/\\/\\/\\') + chalk.white('       | RIP |'));
  console.log(chalk.white('  |_____|    NAVIGATOR       |_____|       FLASH       |_____|'));
  console.log(chalk.gray('═══════════════════════════════════════════════════════════════'));
  console.log(chalk.green('  ~  ^   ~   ^    ~    ^    ~    ^    ~     ^    ~    ^    ~'));
  console.log('');
  console.log(chalk.gray('        The Graveyard of Deprecated Technologies\n'));
}

// Main program
program
  .name('boocli')
  .description('A spooky interactive ghost companion for your terminal 👻')
  .version('1.0.0');

program
  .command('haunt')
  .description('Get haunted by a random ghost')
  .action(haunt);

program
  .command('fortune')
  .description('Receive a spooky fortune from the Ghost King')
  .action(tellFortune);

program
  .command('story')
  .description('Listen to a ghostly tale of tech horror')
  .action(tellStory);

program
  .command('summon')
  .description('Summon an interactive ghost companion')
  .action(summon);

program
  .command('graveyard')
  .description('Visit the graveyard of deprecated technologies')
  .action(() => {
    console.clear();
    showGraveyard();
  });

// Default action when no command is provided
program.action(async () => {
  await summon();
});

program.parse(process.argv);

// If no arguments, run summon by default
if (!process.argv.slice(2).length) {
  summon();
}
