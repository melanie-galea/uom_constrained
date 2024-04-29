import sacrebleu
import argparse

def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.readlines()

def calculate_score_report(srcfile, reffile, notok):
    print("in calculate score report")
    
    src_lines = read_file(srcfile)
    ref_lines = read_file(reffile)
    
    if notok:
        print("NO TOK")
        chrf = sacrebleu.corpus_chrf(src_lines, [ref_lines], tokenized=False)
        bleu = sacrebleu.corpus_bleu(src_lines, [ref_lines], tokenized=False)
    else:
        chrf = sacrebleu.corpus_chrf(src_lines, [ref_lines])
        bleu = sacrebleu.corpus_bleu(src_lines, [ref_lines])

    return bleu.score

if __name__ == '__main__':
    print("IN MAIN")
    parser = argparse.ArgumentParser()

    parser.add_argument('--system_output', '--sys', type=str, help='File with each line-by-line model outputs')
    parser.add_argument('--gold_reference', '--ref', type=str, help='File with corresponding line-by-line references')
    parser.add_argument('--notok', action='store_const', const=True, default=False, help='tokenize or not (default false)')
    args = parser.parse_args()
    bleu_score = calculate_score_report(srcfile=args.system_output, reffile=args.gold_reference, notok=args.notok)
    print("BLEU Score:", bleu_score)
