/* eslint-disable no-await-in-loop */
/* eslint-disable import/no-dynamic-require */
/* eslint-disable no-sequences */
import { execSync, ExecSyncOptions } from 'child_process';
import { existsSync, readFileSync, writeFileSync } from 'fs';
import net from 'net';
import os from 'os';

const exec = (command: string, args?: ExecSyncOptions) => {
    try {
        return {
            output: execSync(command, args).toString(),
            code: 0,
        };
    } catch (e) {
        return {
            code: e.status,
            message: e.message,
        };
    }
};
const sleep = (t: number) => new Promise((r) => { setTimeout(r, t); });
const locales = {
    zh: {
        'install.start': '开始运行 Hydro 安装工具',
        'warn.avx': '检测到您的 CPU 不支持 avx 指令集，将使用 mongodb@v4.4',
        'error.rootRequired': '请先使用 sudo su 切换到 root 用户后再运行该工具。',
        'error.unsupportedArch': '不支持的架构 %s ,请尝试手动安装。',
        'error.osreleaseNotFound': '无法获取系统版本信息（/etc/os-release 文件未找到），请尝试手动安装。',
        'error.unsupportedOS': '不支持的操作系统 %s ，请尝试手动安装，',
        'install.preparing': '正在初始化安装...',
        'install.mongodb': '正在安装 mongodb...',
        'install.createDatabaseUser': '正在创建数据库用户...',
        'install.compiler': '正在安装编译器...',
        'install.hydro': '正在安装 Hydro...',
        'install.done': 'Hydro 安装成功！',
        'install.alldone': '安装已全部完成。',
        'install.editJudgeConfigAndStart': '请编辑 ~/.hydro/judge.yaml 后使用 pm2 start hydrojudge && pm2 save 启动。',
        'extra.dbUser': '数据库用户名： hydro',
        'extra.dbPassword': '数据库密码： %s',
        'info.skip': '步骤已跳过。',
        'error.bt': `检测到宝塔面板，安装脚本很可能无法正常工作。建议您使用纯净的 Ubuntu 22.04 系统进行安装。
要忽略该警告，请使用 --shamefully-unsafe-bt-panel 参数重新运行此脚本。`,
        'warn.bt': `检测到宝塔面板，这会对系统安全性与稳定性造成影响。建议使用纯净 Ubuntu 22.04 系统进行安装。
开发者对因为使用宝塔面板的数据丢失不承担任何责任。
要取消安装，请使用 Ctrl-C 退出。安装程序将在五秒后继续。`,
        'migrate.hustojFound': `检测到 HustOJ。安装程序可以将 HustOJ 中的全部数据导入到 Hydro。（原有数据不会丢失，您可随时切换回 HustOJ）
该功能支持原版 HustOJ 和部分修改版，输入 y 确认该操作。
迁移过程有任何问题，欢迎加QQ群 1085853538 咨询管理员。`,
    },
    en: {
        'install.start': 'Starting Hydro installation tool',
        'warn.avx': 'Your CPU does not support avx, will use mongodb@v4.4',
        'error.rootRequired': 'Please run this tool as root user.',
        'error.unsupportedArch': 'Unsupported architecture %s, please try to install manually.',
        'error.osreleaseNotFound': 'Unable to get system version information (/etc/os-release file not found), please try to install manually.',
        'error.unsupportedOS': 'Unsupported operating system %s, please try to install manually.',
        'install.preparing': 'Initializing installation...',
        'install.mongodb': 'Installing mongodb...',
        'install.createDatabaseUser': 'Creating database user...',
        'install.compiler': 'Installing compiler...',
        'install.hydro': 'Installing Hydro...',
        'install.done': 'Hydro installation completed!',
        'install.alldone': 'Hydro installation completed.',
        'install.editJudgeConfigAndStart': 'Please edit config at ~/.hydro/judge.yaml than start hydrojudge with:\npm2 start hydrojudge && pm2 save.',
        'extra.dbUser': 'Database username: hydro',
        'extra.dbPassword': 'Database password: %s',
        'info.skip': 'Step skipped.',
        'error.bt': `BT-Panel detected, this script may not work properly. It is recommended to use a pure Ubuntu 22.04 OS.
To ignore this warning, please run this script again with '--shamefully-unsafe-bt-panel' flag.`,
        'warn.bt': `BT-Panel detected, this will affect system security and stability. It is recommended to use a pure Ubuntu 22.04 OS.
The developer is not responsible for any data loss caused by using BT-Panel.
To cancel the installation, please use Ctrl-C to exit. The installation program will continue in five seconds.`,
        'migrate.hustojFound': `HustOJ detected. The installation program can migrate all data from HustOJ to Hydro.
The original data will not be lost, and you can switch back to HustOJ at any time.
This feature supports the original version of HustOJ and some modified versions. Enter y to confirm this operation.
If you have any questions about the migration process, please add QQ group 1085853538 to consult the administrator.`,
    },
};
const locale = 'zh';
const processLog = (orig) => (str, ...args) => (orig(locales[locale][str] || str, ...args), 0);
const log = {
    info: processLog(console.log),
    warn: processLog(console.warn),
    fatal: (str, ...args) => (processLog(console.error)(str, ...args), process.exit(1)),
};

let retry = 0;
log.info('install.start');
const defaultDict = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
function randomstring(digit = 32, dict = defaultDict) {
    let str = '';
    for (let i = 1; i <= digit; i++) str += dict[Math.floor(Math.random() * dict.length)];
    return str;
}
let password = randomstring(32);
// eslint-disable-next-line
let CN = true;

const noCaddy = process.argv.includes('--no-caddy');
const addons = ['@hydrooj/ui-default', '@hydrooj/fps-importer', '@hydrooj/a11y'];
const installTarget = `${addons.join(' ')}`;
let avx = true;
const cpuInfoFile = readFileSync('/proc/cpuinfo', 'utf-8');
if (!cpuInfoFile.includes('avx')) {
    avx = false;
    log.warn('warn.avx');
}

const nixProfile = `${process.env.HOME}/.nix-profile/`;
const entry = (source: string, target = source, ro = true) => `\
  - type: bind
    source: ${source}
    target: ${target}${ro ? '\n    readonly: true' : ''}`;
const mount = `mount:
${entry(`${nixProfile}bin`, '/bin')}
${entry(`${nixProfile}bin`, '/usr/bin')}
${entry(`${nixProfile}lib`, '/lib')}
${entry(`${nixProfile}share`, '/share')}
${entry(`${nixProfile}etc`, '/etc')}
${entry('/nix', '/nix')}
${entry('/dev/null', '/dev/null', false)}
${entry('/dev/urandom', '/dev/urandom', false)}
  - type: tmpfs
    target: /w
    data: size=512m,nr_inodes=8k
  - type: tmpfs
    target: /tmp
    data: size=512m,nr_inodes=8k
proc: true
workDir: /w
hostName: executor_server
domainName: executor_server
uid: 1536
gid: 1536
`;
const Caddyfile = `\
# 如果你希望使用其他端口或使用域名，修改此处 :80 的值后在 ~/.hydro 目录下使用 caddy reload 重载配置。
# 如果你在当前配置下能够通过 http://你的域名/ 正常访问到网站，若需开启 ssl，
# 仅需将 :80 改为你的域名（如 hydro.ac）后使用 caddy reload 重载配置即可自动签发 ssl 证书。
# 填写完整域名，注意区分有无 www （www.hydro.ac 和 hydro.ac 不同，请检查 DNS 设置）
# 请注意在防火墙/安全组中放行端口，且部分运营商会拦截未经备案的域名。
# For more information, refer to caddy v2 documentation.
:80 {
  encode zstd gzip
  log {
    output file /data/access.log {
      roll_size 1gb
      roll_keep_for 72h
    }
    format json
  }
  # Handle static files directly, for better performance.
  root * /root/.hydro/static
  @static {
    file {
      try_files {path}
    }
  }
  handle @static {
    file_server
  }
  handle {
    reverse_proxy http://127.0.0.1:8888
  }
}

# 如果你需要同时配置其他站点，可参考下方设置：
# 请注意：如果多个站点需要共享同一个端口（如 80/443），请确保为每个站点都填写了域名！
# 动态站点：
# xxx.com {
#    reverse_proxy http://127.0.0.1:1234
# }
# 静态站点：
# xxx.com {
#    root * /www/xxx.com
#    file_server
# }
`;

const nixConfBase = `
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydro.ac:EytfvyReWHFwhY9MCGimCIn46KQNfmv9y8E2NqlNfxQ=
connect-timeout = 10
experimental-features = nix-command flakes
`;

const isPortFree = async (port: number) => {
    const server = net.createServer();
    const res = await new Promise((resolve) => {
        server.once('error', () => resolve(false));
        server.once('listening', () => resolve(true));
        server.listen(port);
    });
    server.close();
    return res;
};

function rollbackResolveField() {
    const yarnGlobalPath = exec('yarn global dir').output?.trim() || '';
    if (!yarnGlobalPath) return false;
    const pkgjson = `${yarnGlobalPath}/package.json`;
    const data = JSON.parse(readFileSync(pkgjson, 'utf-8'));
    delete data.resolutions;
    writeFileSync(pkgjson, JSON.stringify(data, null, 2));
    return true;
}

function removeOptionalEsbuildDeps() {
    const yarnGlobalPath = exec('yarn global dir').output?.trim() || '';
    if (!yarnGlobalPath) return false;
    const pkgjson = `${yarnGlobalPath}/package.json`;
    const data = existsSync(pkgjson) ? require(pkgjson) : {};
    data.resolutions ||= {};
    Object.assign(data.resolutions, Object.fromEntries([
        '@esbuild/linux-loong64',
        'esbuild-windows-32',
        ...['android', 'darwin', 'freebsd', 'windows']
            .flatMap((i) => [`${i}-64`, `${i}-arm64`])
            .map((i) => `esbuild-${i}`),
        ...['32', 'arm', 'mips64', 'ppc64', 'riscv64', 's390x']
            .map((i) => `esbuild-linux-${i}`),
        ...['netbsd', 'openbsd', 'sunos']
            .map((i) => `esbuild-${i}-64`),
    ].map((i) => [i, 'link:/dev/null'])));
    exec(`mkdir -p ${yarnGlobalPath}`);
    writeFileSync(pkgjson, JSON.stringify(data, null, 2));
    return true;
}

const mem = os.totalmem() / 1024 / 1024 / 1024; // In GiB
// TODO: refuse to install if mem < 1.5
const wtsize = Math.max(0.25, Math.floor((mem / 6) * 100) / 100);

const printInfo = [
    () => {
        const config = require(`${process.env.HOME}/.hydro/config.json`);
        if (config.uri) password = new URL(config.uri).password || '(No password)';
        else password = config.password || '(No password)';
        log.info('extra.dbUser');
        log.info('extra.dbPassword', password);
    },
];

const Steps = () => [
    {
        init: 'install.preparing',
        operations: [
            () => {
                if (!CN) {
                    writeFileSync('/etc/nix/nix.conf', `substituters = https://cache.nixos.org/ https://nix.hydro.ac/cache
${nixConfBase}`);
                }
                if (CN) return;
                // rollback mirrors
                exec('nix-channel --remove nixpkgs', { stdio: 'inherit' });
                exec('nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs', { stdio: 'inherit' });
                exec('nix-channel --update', { stdio: 'inherit' });
            },
            'nix-env -iA nixpkgs.pm2 nixpkgs.yarn nixpkgs.esbuild nixpkgs.bash nixpkgs.unzip nixpkgs.zip nixpkgs.diffutils nixpkgs.patch',
        ],
    },
    {
        init: 'install.mongodb',
        operations: [
            () => writeFileSync(`${process.env.HOME}/.config/nixpkgs/config.nix`, `\
{
    permittedInsecurePackages = [
        "openssl-1.1.1t"
        "openssl-1.1.1u"
        "openssl-1.1.1v"
        "openssl-1.1.1w"
        "openssl-1.1.1x"
        "openssl-1.1.1y"
        "openssl-1.1.1z"
    ];
}`),
            `nix-env -iA hydro.mongodb${avx ? 6 : 4}${CN ? '-cn' : ''} nixpkgs.mongosh nixpkgs.mongodb-tools`,
            'bun i -g mongodb',
        ],
    },

    {
        init: 'install.caddy',
        skip: () => !exec('caddy version').code || noCaddy,
        operations: [
            'nix-env -iA nixpkgs.caddy',
            () => writeFileSync(`${process.env.HOME}/.hydro/Caddyfile`, Caddyfile),
        ],
    },
    {
        init: 'install.hydro',
        operations: [
            () => removeOptionalEsbuildDeps(),
            [`bun i -g ${installTarget}`, { retry: true }],
            () => {
                writeFileSync(`${process.env.HOME}/.hydro/addon.json`, JSON.stringify(addons));
            },
            () => rollbackResolveField(),
        ],
    },
    {
        init: 'install.createDatabaseUser',
        skip: () => existsSync(`${process.env.HOME}/.hydro/config.json`),
        operations: [
            'pm2 start mongod',
            () => sleep(3000),
            async () => {
                // eslint-disable-next-line
                const { MongoClient, WriteConcern } = require('/root/.bun/install/global/node_modules/mongodb') as typeof import('mongodb');
                const client = await MongoClient.connect('mongodb://127.0.0.1', {
                    readPreference: 'nearest',
                    writeConcern: new WriteConcern('majority'),
                });
                await client.db('hydro').command({
                    createUser: 'hydro',
                    pwd: password,
                    roles: [{ role: 'readWrite', db: 'hydro' }],
                });
                await client.close();
            },
            () => writeFileSync(`${process.env.HOME}/.hydro/config.json`, JSON.stringify({
                uri: `mongodb://hydro:${password}@127.0.0.1:27017/hydro`,
            })),
            'pm2 stop mongod',
            'pm2 del mongod',
        ],
    },
    {
        init: 'install.starting',
        operations: [
            ['pm2 stop all', { ignore: true }],
            () => writeFileSync(`${process.env.HOME}/.hydro/mount.yaml`, mount),
            // eslint-disable-next-line max-len
            ...[
                () => console.log(`WiredTiger cache size: ${wtsize}GB`),
                `pm2 start mongod --name mongodb -- --auth --bind_ip 0.0.0.0 --wiredTigerCacheSizeGB=${wtsize}`,
                () => sleep(1000),
                'pm2 start bun --name hydrooj -- start',
                async () => {
                    if (noCaddy) return;
                    if (!await isPortFree(80)) log.warn('port.80');
                    exec('pm2 start caddy -- run', { cwd: `${process.env.HOME}/.hydro` });
                    exec('hydrooj cli system set server.xff x-forwarded-for');
                    exec('hydrooj cli system set server.xhost x-forwarded-host');
                },
            ],
            'pm2 startup',
            'pm2 save',
        ],
    },
    {
        init: 'install.done',
        operations: printInfo,
    },
    {
        init: 'install.postinstall',
        operations: [
            'echo "vm.swappiness = 1" >>/etc/sysctl.conf',
            'sysctl -p',
            ['pm2 install pm2-logrotate', { retry: true }],
            'pm2 set pm2-logrotate:max_size 64M',
        ],
    },
    {
        init: 'install.alldone',
        operations: [
            ...printInfo,
            () => log.info('install.alldone'),
        ],
    },
];

async function main() {
    try {
        if (process.env.REGION) {
            if (process.env.REGION !== 'CN') CN = false;
        } else {
            console.log('Getting IP info to find best mirror:');
            const res = await fetch('https://ipinfo.io', { headers: { accept: 'application/json' } }).then((r) => r.json());
            delete res.readme;
            console.log(res);
            if (res.country !== 'CN') CN = false;
        }
    } catch (e) {
        console.error(e);
        console.log('Cannot find the best mirror. Fallback to default.');
    }
    const steps = Steps();
    for (let i = 0; i < steps.length; i++) {
        const step = steps[i];
        if (!(step.skip?.())) {
            for (let op of step.operations) {
                if (!(op instanceof Array)) op = [op, {}] as any;
                if (op[0].toString().startsWith('nix-env')) op[1].retry = true;
                if (typeof op[0] === 'string') {
                    retry = 0;
                    let res = exec(op[0], { stdio: 'inherit' });
                    while (res.code && op[1].ignore !== true) {
                        if (op[1].retry && retry < 30) {
                            log.warn('Retry... (%s)', op[0]);
                            res = exec(op[0], { stdio: 'inherit' });
                            retry++;
                        } else log.fatal('Error when running %s', op[0]);
                    }
                } else {
                    retry = 0;
                    let res = await op[0](op[1]);
                    while (res === 'retry') {
                        if (retry < 30) {
                            log.warn('Retry...');
                            // eslint-disable-next-line no-await-in-loop
                            res = await op[0](op[1]);
                            retry++;
                        } else log.fatal('Error installing');
                    }
                }
            }
        }
    }
}
main().catch(log.fatal);
global.main = main;
