import kenlm
model = kenlm.Model('drive/MyDrive/iwslt/models/mt/kenlm_mt3.arpa')

import abc
import numpy as np
from transformers import AutoTokenizer


class Token:
    def __init__(self, text: str):
        self.text = text if text == "+" else text.rstrip("+")
        self.merges_with_next = text.endswith("+") and text != "+"


class TokenRanker(abc.ABC):
    best_score_selector = max
    """
    The function to use when choosing the best score.
    This can be overridden by inheritors & is mostly applicable with the default implementation of :py:meth:`~TokenRanker.filter_best`.
    """

    def filter_best(self, alternatives: list[Token]) -> list[Token]:
        """
        Args:
            alternatives: All the alternative tokens to consider.

        Returns:
            The filtered list of alternatives which have the best score.
            If multiple alternatives are given,
            this means that all the alternatives are considered equally good by the :class:`TokenRanker`.
        """
        scores = self.score([alternative.text for alternative in alternatives])
        return np.asarray(alternatives)[np.asarray(scores) == self.best_score_selector(scores)]

    @abc.abstractmethod
    def score(self, alternatives: list[str]) -> list[float]:
        """
        Args:
            alternatives: All the alternative tokens to consider.

        Returns:
            A score for each token of the given ``alternatives``.
        """
        pass


class RandomRanker(TokenRanker):
    """
    Ranks tokens by sorting them alphabetically.
    """

    def filter_best(self, alternatives: list[Token]) -> list[Token]:
        return [sorted(alternatives, key=lambda token: token.text)[0]]

    def score(self, alternatives: list[str]) -> list[float]:
        pass


class SubTokensCountRanker(TokenRanker):
    """
    Ranks tokens by the number of sub-tokens given by the underlying tokenizer.
    """

    best_score_selector = min

    def __init__(self, name: str):
        """
        Args:
            name: The name or path to the tokenizer to use from the ``transformers`` library.
        """
        self.tokenizer = AutoTokenizer.from_pretrained(name)

    def score(self, alternatives: list[str]) -> list[float]:
        return self.tokenizer(alternatives, add_special_tokens=False, return_length=True)["length"]


class WordModelScoreRanker(TokenRanker):
    """
    Ranks tokens by the word n-gram language model score.
    """

    def __init__(self, name: str):
        """
        Args:
            name: The path to the model to use through the ``kenlm`` library.
        """
        self.model = kenlm.Model(name)

    def score(self, alternatives: list[str]) -> list[float]:
        return [self.model.score(token) for token in alternatives]


class CharacterModelScoreRanker(TokenRanker):
    """
    Ranks tokens by the character n-gram language model score.
    """

    def __init__(self, name: str):
        """
        Args:
            name: The path to the model to use through the ``kenlm`` library.
        """
        self.model = kenlm.Model(name)

    def score(self, alternatives: list[str]) -> list[float]:
        return [self.model.score(' '.join(token)) for token in alternatives]

def fix_spelling(sentence, ranker):
    # Tokenize the sentence
    tokens = sentence.strip().split(' ')
    print("this is tokens: ", tokens[1])

    # Rank the tokens
    token_objects = [Token(token) for token in tokens]
    best_tokens = ranker.filter_best(token_objects)
    for token in best_tokens:
      print("here: ", token.text)

    # Replace misspelled tokens with best-ranked tokens
    corrected_sentence = " ".join(token.text for token in best_tokens)

    return corrected_sentence
