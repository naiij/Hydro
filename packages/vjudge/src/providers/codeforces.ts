/* eslint-disable no-await-in-loop */
import superagent from 'superagent';
import { JSDOM } from 'jsdom';
import { STATUS } from '@hydrooj/utils/lib/status';
import { sleep } from '@hydrooj/utils/lib/utils';
import { buildContent } from 'hydrooj/dist/lib/content';
import { Logger } from 'hydrooj/dist/logger';
import { PassThrough } from 'stream';
import { IBasicProvider, RemoteAccount } from '../interface';

const logger = new Logger('codeforces');

const VERDICT = {
    RUNTIME_ERROR: STATUS.STATUS_RUNTIME_ERROR,
    WRONG_ANSWER: STATUS.STATUS_WRONG_ANSWER,
    OK: STATUS.STATUS_ACCEPTED,
    TIME_LIMIT_EXCEEDED: STATUS.STATUS_TIME_LIMIT_EXCEEDED,
    MEMORY_LIMIT_EXCEEDED: STATUS.STATUS_MEMORY_LIMIT_EXCEEDED,
    IDLENESS_LIMIT_EXCEEDED: STATUS.STATUS_TIME_LIMIT_EXCEEDED,
    Accepted: STATUS.STATUS_ACCEPTED,
    'Wrong answer': STATUS.STATUS_WRONG_ANSWER,
    'Runtime error': STATUS.STATUS_RUNTIME_ERROR,
    'Time limit exceeded': STATUS.STATUS_TIME_LIMIT_EXCEEDED,
    'Memory limit exceeded': STATUS.STATUS_MEMORY_LIMIT_EXCEEDED,
    'Idleness limit exceeded': STATUS.STATUS_TIME_LIMIT_EXCEEDED,
};

export default class CodeforcesProvider implements IBasicProvider {
    constructor(public account: RemoteAccount, private save: (data: any) => Promise<void>) {
        if (account.cookie) this.cookie = account.cookie;
    }

    cookie: string[] = [];
    // @ts-ignore
    ftaa = String.random(18, 'abcdef1234567890');
    csrf: string;

    get(url: string) {
        logger.debug('get', url);
        return superagent.get(`https://codeforces.com${url}`).set('Cookie', this.cookie);
    }

    post(url: string) {
        logger.debug('post', url, this.cookie);
        return superagent.post(`https://codeforces.com${url}`).type('form').set('Cookie', this.cookie);
    }

    tta(_39ce7: string) {
        let _tta = 0;
        for (let c = 0; c < _39ce7.length; c++) {
            _tta = (_tta + (c + 1) * (c + 2) * _39ce7.charCodeAt(c)) % 1009;
            if (c % 3 === 0) _tta++;
            if (c % 2 === 0) _tta *= 2;
            if (c > 0) _tta -= Math.floor(_39ce7.charCodeAt(Math.floor(c / 2)) / 2) * (_tta % 5);
            _tta = ((_tta % 1009) + 1009) % 1009;
        }
        return _tta;
    }

    async getCsrfToken(url: string) {
        const { text: html, header } = await this.get(url);
        if (header['set-cookie']) {
            await this.save({ cookie: header['set-cookie'] });
            this.cookie = header['set-cookie'];
        }
        const $dom = new JSDOM(html);
        return $dom.window.document.querySelector('meta[name="X-Csrf-Token"]').getAttribute('content');
    }

    get loggedIn() {
        return this.get('/').then(({ text: html }) => {
            const $dom = new JSDOM(html);
            if (!$dom.window.document.querySelectorAll('a[href="/enter?back=%2F"]').length) return true;
            return false;
        });
    }

    async ensureLogin() {
        if (await this.loggedIn) return true;
        logger.info('retry login');
        const csrf_token = await this.getCsrfToken('/enter');
        const res = await this.post('/enter').send({
            csrf_token,
            action: 'enter',
            ftaa: '',
            bfaa: '',
            handleOrEmail: this.account.handle,
            password: this.account.password,
            remember: 'on',
        });
        const cookie = res.header['set-cookie'];
        if (cookie) {
            await this.save({ cookie });
            this.cookie = cookie;
        }
        if (await this.loggedIn) return true;
        return false;
    }

    async getProblem(id: string) {
        logger.info(id);
        const [, contestId, problemId] = /^P(\d+)([A-Z][0-9]?)$/.exec(id);
        const res = await this.get(`/problemset/problem/${contestId}/${problemId}`);
        if (!res.text) return null;
        const $dom = new JSDOM(res.text.replace(/\$\$\$/g, '$'));
        const tag = Array.from($dom.window.document.querySelectorAll('.tag-box')).map((i) => i.textContent.trim());
        const text = $dom.window.document.querySelector('.problem-statement').innerHTML;
        const { window: { document } } = new JSDOM(text);
        const files = {};
        document.querySelectorAll('img[src]').forEach((ele) => {
            const src = ele.getAttribute('src');
            if (!src.startsWith('http')) return;
            const file = new PassThrough();
            superagent.get(src).pipe(file);
            const fid = String.random(8);
            files[`${fid}.png`] = file;
            ele.setAttribute('src', `file://${fid}.png`);
        });
        const title = document.querySelector('.title').innerHTML.trim().split('. ')[1];
        const time = parseInt(document.querySelector('.time-limit').innerHTML.substr(53, 2), 10);
        const memory = parseInt(document.querySelector('.memory-limit').innerHTML.substr(55, 4), 10);
        document.body.firstChild.remove();
        document.querySelector('.input-specification')?.firstChild.remove();
        document.querySelector('.output-specification')?.firstChild.remove();
        document.querySelector('.note')?.firstChild.remove();
        const input = document.querySelector('.input-specification')?.innerHTML.trim();
        const output = document.querySelector('.output-specification')?.innerHTML.trim();
        const inputs = Array.from(document.querySelectorAll('.input>pre')).map((i) => i.innerHTML.trim());
        const outputs = Array.from(document.querySelectorAll('.output>pre')).map((i) => i.innerHTML.trim());
        const note = document.querySelector('.note')?.innerHTML.trim();
        document.querySelector('.note')?.remove();
        document.querySelector('.sample-tests')?.remove();
        document.querySelectorAll('.section-title').forEach((ele) => {
            const e = document.createElement('h2');
            e.innerHTML = ele.innerHTML;
            ele.replaceWith(e);
        });
        const description = document.body.innerHTML.trim();
        return {
            title,
            data: {
                'config.yaml': Buffer.from(`time: ${time}s\nmemory: ${memory}m\ntype: remote_judge\nsubType: codeforces\ntarget: ${id}`),
            },
            files,
            tag,
            content: buildContent([
                {
                    type: 'Text', sectionTitle: 'Description', subType: 'markdown', text: description,
                },
                ...input ? [{
                    type: 'Text', sectionTitle: 'Input', subType: 'markdown', text: input,
                }] : [],
                ...output ? [{
                    type: 'Text', sectionTitle: 'Output', subType: 'markdown', text: output,
                }] : [],
                ...inputs.map((_, i) => ({
                    type: 'Sample', payload: [inputs[i], outputs[i]], text: '', sectionTitle: 'Samples',
                }) as any),
                ...note ? [{
                    type: 'Text', sectionTitle: 'Note', subType: 'markdown', text: note,
                }] : [],
            ]),
        };
    }

    async listProblem(page: number) {
        const res = await this.get(`/problemset/page/${page}`);
        const $dom = new JSDOM(res.text);
        const index = $dom.window.document.querySelector('.page-index.active').getAttribute('pageindex');
        if (index !== page.toString()) return [];
        return Array.from($dom.window.document.querySelectorAll('.id>a')).map((i) => `P${i.innerHTML.trim()}`);
    }

    async submitProblem(id: string, lang: string, code: string) {
        const programTypeId = lang.includes('codeforces.') ? lang.split('codeforces.')[1] : '42';
        const [, contestId, submittedProblemIndex] = /^P(\d+)([A-Z][0-9]?)$/.exec(id);
        const csrf_token = await this.getCsrfToken('/problemset/submit');
        // TODO check submit time to ensure submission
        await this.post(`/problemset/submit?csrf_token=${csrf_token}`).send({
            csrf_token,
            contestId,
            action: 'submitSolutionFormSubmitted',
            programTypeId,
            submittedProblemIndex,
            source: code,
            tabsize: 4,
            sourceFile: '',
            ftaa: '',
            bfaa: 'f1b3f18c715565b589b7823cda7448ce',
            _tta: 594,
            sourceCodeConfirmed: true,
        });
        const { text: info } = await this.get('/problemset/status?my=on');
        const $dom = new JSDOM(info);
        this.csrf = $dom.window.document.querySelector('meta[name="X-Csrf-Token"]').getAttribute('content');
        return $dom.window.document.querySelector('[data-submission-id]').getAttribute('data-submission-id');
    }

    async waitForSubmission(id: string, next, end) {
        let i = 1;
        // eslint-disable-next-line no-constant-condition
        while (true) {
            await sleep(3000);
            const { body } = await this.post('/data/submitSource').send({
                csrf_token: this.csrf,
                submissionId: id,
            });
            if (body.compilationError === 'true') {
                await next({ compilerText: body['checkerStdoutAndStderr#1'] });
                return await end({
                    status: STATUS.STATUS_COMPILE_ERROR, score: 0, time: 0, memory: 0,
                });
            }
            const time = Math.sum(Object.keys(body).filter((k) => k.startsWith('timeConsumed#')).map((k) => +body[k]));
            const memory = Math.max(...Object.keys(body).filter((k) => k.startsWith('memoryConsumed#')).map((k) => +body[k])) / 1024;
            for (; i <= +body.testCount; i++) {
                const status = VERDICT[body[`verdict#${i}`]] || STATUS.STATUS_WRONG_ANSWER;
                await next({
                    status: STATUS.STATUS_JUDGING,
                    case: {
                        status,
                        time: +body[`timeConsumed#${i}`],
                        memory: +body[`memoryConsumed#${i}`] / 1024,
                        message: body[`checkerStdoutAndStderr#${i}`] || body[`verdict#${i}`],
                    },
                });
            }
            if (body.waiting === 'true') continue;
            const status = VERDICT[Object.keys(VERDICT).filter((k) => body.verdict.includes(k))[0]];
            return await end({
                status,
                score: status === STATUS.STATUS_ACCEPTED ? 100 : 0,
                time,
                memory,
            });
        }
    }
}
