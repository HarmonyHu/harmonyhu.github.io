---
layout: single
title: LLM的采样策略
categories:
  - AI
tags:
  - AI编程
---

* content
{:toc}
  

LLM的decode阶段会输出`vocab_size`个数值，本文用logits表示。每个位置对应词典每个token。选择哪个token，有不同的策略。

参考链接：[logits_process.py](https://github.com/huggingface/transformers/blob/main/src/transformers/generation/logits_process.py)

# 贪心解码

Greedy Decoding，也就是直接选择数值最大的那个位置的token。示例代码如下：

``` python
# logits is [vocab_size]
logit, token = torch.topk(logits, 1)
```



# 随机采样

参数说明：

* `temperature`:  控制文本的随机性，越高随机性越强。算法上用于运算 `logits = logits/temperature`

* `repetition_penalty`:  用于减少文本中的重复，对已经出现过的token，一般数值为1.2。做操作如下：

  ``` python
  logit = logit * repetition_penalty if logit < 0 else logit / repetition_penalty
  ```

* `top_k`: 选取数值最大的`top_k`个结果，一般为40到100之间

* `top_p`: 指定概率，累计概率在`top_p`以内的会被选择，一般指定为0.7到1.0之间，比如0.8。

  举例概率列表`[0.25, 0.20, 0.15, 0.1, 0.07, 0.06, 0.05, 0.04, 0.03, 0.01]`，累计概率为cumsum，得到`[0.25, 0.45, 0.60, 0.70, 0.77, 0.83]`，0.83开始超出了`top_p`，所以只选择`0.83`之前的部分



计算过程：

``` python
# repetition penalty
def encode_repetition(input_ids, scores):
    score = torch.gather(scores, 1, input_ids)
    score = torch.where(score < 0, score * penalty, score / penalty)
    scores_processed = scores.scatter(1, input_ids, score)
    return scores_processed

def encode_topp(scores):
    cumulative_probs = scores.softmax(-1).cumsum(-1) # probility
    sorted_indices_to_remove = cumulative_probs <= (1 - self.top_p)
    sorted_indices_to_remove[..., -self.min_tokens_to_keep :] = 0
    indices_to_remove = sorted_indices_to_remove.scatter(1, sorted_indices, sorted_indices_to_remove)
    scores_processed = scores.masked_fill(indices_to_remove, "-inf")

logits = encode_repetition(input_ids, logits)    # repetition
logits, indices = torch.topk(logits, top_k)      # top_k
logits = logits/temperature                      # temperature
logits = encode_top_p(logits)                    # top_p
probabilities = logits.softmax(-1)               # 
```

