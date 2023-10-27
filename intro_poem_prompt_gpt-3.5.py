import openai

openai.api_key = "<API-Key>"

poem_topic = "Empirical Evidence of excess profits in european stock markets prior to ECB monetary policy decisions."
topic_desc = "which is about patterns in financial markets and monetary policy in the field of economics and finance"
parameters = "with a maximum of 100 words using words and phrases used in academia"
prompt = "Write a poem about " + poem_topic + " " + topic_desc +" " + parameters

response = openai.chat.completions.create(
    model='gpt-3.5-turbo',
    messages=[{"role": "user", "content": prompt}],
    temperature=0)

print(response.choices[0].message.content)