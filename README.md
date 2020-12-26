# CloudPay

Simple and flexible CloudPayments API client. (https://developers.cloudpayments.ru/, https://developers.cloudpayments.ru/en/)

## Difference from `cloud_payments` gem

It's a kind of fork of the `cloud_payments` gem. The main idea to build a simple and flexible client.

So what is the difference:

`CloudPay`

- has fewer dependencies. It depends on only the `faraday` gem.
- doesn't contain value objects for responses. Now, it is the responsibility of an app to provide value objects for all responses.
- has a flexible system of configuration.
- provides an ability to send idempotent requests.
- allows using of namespaces as standalone classes.
- provides a unified interface for API methods.
- has two ways to handle errors: with exceptions and result object.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloud_pay'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install cloud_pay
```

## Usage

### Configuration

We can have a few configuration presets. It's easy to define using the `CloudPay.configure` method. Example:

```ruby
CloudPay.configure do |c|
  # default configuration preset
end

CloudPay.confugure(:preset_name) do |c|
  # named configuration preset
end
```

Then, we can select the needed config when we are creating a client:

```ruby
config = CloudPay::Config.new(host: '...')

CloudPay.client # Client with default config
CloudPay.client(:preset_name) # Client with predefined config
CloudPay::Client.new
CloudPay::Client.new(:preset_name)
```

Also, we can configure the client using an instance of the `CloudPay::Config` class or hash.

```ruby
config = CloudPay::Config.new(host: '...')

CloudPay.client(host: '...')
CloudPay.client(config)
CloudPay::Client.new(host: '...')
CloudPay::Client.new(config)
```

This way to resolve config is also applied to all API namespaces and webhooks handler.

```ruby
# Namespaces
CloudPay::Payments::Tokens.new
CloudPay::Payments::Tokens.new(:preset_name)
CloudPay::Payments::Tokens.new(host: '...')
CloudPay::Payments::Tokens.new(config)

# Webhooks
CloudPay::Webhooks.new
CloudPay::Webhooks.new(:preset_name)
CloudPay::Webhooks.new(host: '...')
CloudPay::Webhooks.new(config)
```

It's also possible to switch the default config for some block of code. It can be used in middlewares, for example.

```ruby
CloudPay.with_config(Rails.env.to_sym) do
  CloudPay.client # Client with `:development`, `:test` or `:production` config
end
```

```ruby
class CloudPayMiddleware
  def call(env)
    config = config_name(env)

    CloudPay.with_config(config) do
      @app.call(env)
    end
  end

  private

  def config_name(env)
    # choose predefined config name according to some conditions
  end
end
```

The example above allows switching configs according to some conditions: domain name, headers, or some other. So when we use `CloudPay::Client.new` in the app, it will use config defined in the middleware.

It's also possible to use a simple hash to initialize the client (or any namespace). Such a solution allows implementing multitenancy systems when the config is a part of application data and cannot be predefined in the config stage.

```ruby
CloudPay::Client.new(public_key: '...', secret_key: '...')
```

__Note:__ All undefined options will be inherit from default config when we use hash as a config. That means we can override some options ad-hoc:

```ruby
CloudPay::Client.new(
  public_key: '...',
  secret_key: '...'
).config
# #<CloudPay::Config:0x00007f8fd1af04e8
#  @connection_block=nil,
#  @connection_options={},
#  @host="https://api.cloudpayments.ru",
#  @log=false,
#  @public_key="...",
#  @secret_key="...">

CloudPay.with_config(:test) do
  CloudPay::Client.new(
    public_key: '...',
    secret_key: '...'
  ).config
# #<CloudPay::Config:0x00007f8fd1af04e8
#  @connection_block=nil,
#  @connection_options={},
#  @host="http://localhost:9292",
#  @log=false,
#  @public_key="...",
#  @secret_key="...">
end
```

### Error Handling

There are two ways to handle errors in the gem: using the result object and using exceptions. We use exceptions when we call a method with an exclamation mark (`!`), and we use the result object otherwise.

The result object has a simple interface that consists of only three meaningful methods: `success?`, `model`, and `error_message`. Every API method returns this result object so that we can check the result of the request. Look at the example below:

```ruby
result = CloudPay.client.payments.cards.charge(params)

if result.success?
  # do something with data using the `model` method.
  # pp result.model
else
  # Handle an error.
  # You can use the `error_message` method to get a real error message or
  # You can use the `model` method to get response data.
  # pp result.model
  # pp result.error_message
end
```

Using an exclamation mark forces the client to raise an exception in case of an unsuccessful response. The specific exception depends on the type of response.

- It can be a `CloulPay::ValidationError` exception if the request has missing attributes.

- It can be an exception inherited from `CloudPay::ServerError` in the `CloudPay::HttpErrors` namespace if an HTTP request is ended with any status code more than or equal to 300.

- It can be an exception inherited from `CloudPay::ReasonedGatewayError` in `CloudPay::GatewayErrors` namespace if `ReasonCode` key in the `Model` object has some meaningful code.

- it can be a `CloudPay::GatewayError` exception if the gem cannot determine a specific reason for an error.

It can also raise other exceptions that depend on the HTTP transport, such as faraday's errors or network errors.

```ruby
begin
  model = CloudPay.client.payments.cards.charge!(params, idempotency_key: idempotency_key)
  # do something with data
rescue CloudPay::ValidationError => e
  # handle validation errors
rescue *CloudPay.retryable_errors => e
  # put in queue to retry later
rescue CloudPay::Error => e
  # handle the rest of errors
end
```

The gem provides a list of retryable errors. This list is needed to catch exceptions that can be the reason for retrying the request. We can redefine this list using the `CloudPay.set_retryable_errors` method.

```ruby
CloudPay.set_retryable_errors([
  CloudPay::GatewayErrors::FormatError,
  CloudPay::GatewayErrors::InsufficientFunds,
  CloudPay::GatewayErrors::Timeout,
  CloudPay::GatewayErrors::CannotReachNetwork,
  CloudPay::GatewayErrors::SystemError,
  Faraday::ConnectionFailed,
  Faraday::TimeoutError
])
```

__Note:__ Use the `idempotency_key` option if you intend to retry requests. It can lead to multiple write-offs of funds if you retry your request without the idempotency key.

```ruby
CloudPay.client.payments.cards.charge(params, idempotency_key: 'some-unique-id')
```

It should be an unique value for every separate payment.

### API methods

This gem supports the following API methods:

- [Test method](https://developers.cloudpayments.ru/en/#test-method) - The method to test the interaction with the API and returns `true` or `false`.

  ```ruby
  CloudPay.client.test
  ```

- [Payment by a Cryptogram](https://developers.cloudpayments.ru/en/#payment-by-a-cryptogram) - The method to make a payment by a cryptogram generated by the Checkout script, Apple Pay, or Google Pay.

  ```ruby
  CloudPay.client.payments.cards.charge(params)
  CloudPay.client.payments.cards.auth(params)
  # or
  ns = CloudPay::Payments::Cards.new
  ns.charge(params)
  ns.auth(params)
  ```

- [3-D Secure Processing](https://developers.cloudpayments.ru/en/#3-d-secure-processing) - The method to complete the payment when 3-D Secure authentication is used.

  ```ruby
  CloudPay.client.payments.cards.post3ds(params)
  # or
  ns = CloudPay::Payments::Cards.new
  ns.post3ds(id, params)
  ```

- [Payment by a Token (Recurring)](https://developers.cloudpayments.ru/en/#payment-by-a-token-recurring) - The method to make a payment by a token received either with payment by cryptogram or via Pay notification.

  ```ruby
  CloudPay.client.payments.tokens.charge(params)
  CloudPay.client.payments.tokens.auth(params)
  # or
  ns = CloudPay::Payments::Tokens.new
  ns.charge(params)
  ns.auth(params)
  ```

- [Payment Confirmation](https://developers.cloudpayments.ru/en/#payment-confirmation) - For payments made by the DMS scheme, you need to confirm a transaction. Confirmation can be done through the Back office or via calling this API method.

  ```ruby
  CloudPay.client.payments.confirm(params)
  # or
  ns = CloudPay::Payments.new
  ns.confirm(params)
  ```

- [Payment Cancellation](https://developers.cloudpayments.ru/en/#payment-cancellation) - Cancellation of payment can be executed through your Back Office or by calling the API method.

  ```ruby
  CloudPay.client.payments.void(id)
  # or
  ns = CloudPay::Payments.new
  ns.void(id)
  ```

  It has a `cancel` alias.

  ```ruby
  CloudPay.client.payments.cancel(id)
  # or
  ns = CloudPay::Payments.new
  ns.cancel(id)
  ```

- [Refund](https://developers.cloudpayments.ru/en/#refund) - Refund can be executed through your Back Office or by calling the API method.

  ```ruby
  CloudPay.client.payments.refund(id, params)
  # or
  ns = CloudPay::Payments.new
  ns.refund(id, params)
  ```

- [Payout by a Cryptogram](https://developers.cloudpayments.ru/en/#payout-by-a-cryptogram) - Payment by a cryptogram can be executed through the calling of this API method.

  ```ruby
  CloudPay.client.payments.cards.topup(params)
  # or
  ns = CloudPay::Payments::Cards.new
  ns.topup(params)
  ```

- [Payout by a Token](https://developers.cloudpayments.ru/en/#payout-by-a-token) - Payout by a token can be executed through the calling of the following API method.

  ```ruby
  CloudPay.client.payments.tokens.topup(params)
  # or
  ns = CloudPay::Payments::Tokens.new
  ns.topup(params)
  ```

- [Transaction Details](https://developers.cloudpayments.ru/en/#transaction-details) - The method returns a transaction details.

  ```ruby
  CloudPay.client.payments.get(id)
  # or
  ns = CloudPay::Payments.new
  ns.get(id)
  ```

- [Payment Status Check](https://developers.cloudpayments.ru/en/#payment-status-check) - The method for payment searching, which returns its status.

  ```ruby
  CloudPay.client.payments.find(invoice_id)
  # or
  ns = CloudPay::Payments.new
  ns.find(invoice_id)
  ```

  This method has two versions. It performs first version by default. However, you can specify the version as an `:version` option in the last argument:

  ```ruby
  CloudPay.client.payments.find(invoice_id, version: 2)
  # or
  ns = CloudPay::Payments.new
  ns.find(invoice_id, version: 2)
  ```

- [Transaction List](https://developers.cloudpayments.ru/en/#transaction-list) - The method to get a list of transactions for a day.

  ```ruby
  CloudPay.client.payments.list(params)
  # or
  ns = CloudPay::Payments.new
  ns.list(params)
  ```

- [Token List](https://developers.cloudpayments.ru/en/#token-list) - The method to get a list of all payment tokens of CloudPayments.

  ```ruby
  CloudPay.client.payments.tokens.list
  # or
  ns = CloudPay::Payments::Tokens.new
  ns.list
  ```

- [Creation of Subscriptions on Recurrent Payments](https://developers.cloudpayments.ru/en/#creation-of-subscriptions-on-recurrent-payments) - The method to create subscriptions on recurrent payments.

  ```ruby
  CloudPay.client.subscriptions.create(params)
  # or
  ns = CloudPay::Subscriptions.new
  ns.create(params)
  ```

- [Subscription Details](https://developers.cloudpayments.ru/en/#subscription-details) - The method to get an information about subscription status.

  ```ruby
  CloudPay.client.subscriptions.get(id)
  # or
  ns = CloudPay::Subscriptions.new
  ns.get(id)
  ```

- [Subscriptions Search](https://developers.cloudpayments.ru/en/#subscriptions-search) - The method to get a list of subscriptions for a particular account.

  ```ruby
  CloudPay.client.subscriptions.find(account_id)
  # or
  ns = CloudPay::Subscriptions.new
  ns.find(account_id)
  ```

- [Recurrent Payments Subscription Change](https://developers.cloudpayments.ru/en/#recurrent-payments-subscription-change) - The method to change a subscription on recurrent payments.

  ```ruby
  CloudPay.client.subscriptions.update(params)
  # or
  ns = CloudPay::Subscriptions.new
  ns.update(params)
  ```

- [Subscription on Recurrent Payments Cancellation](https://developers.cloudpayments.ru/en/#subscription-on-recurrent-payments-cancellation) - The method to cancel subscription on recurrent payments.

  ```ruby
  CloudPay.client.subscriptions.cancel(id)
  # or
  ns = CloudPay::Subscriptions.new
  ns.cancel(id)
  ```

- [Invoice Creation on Email](https://developers.cloudpayments.ru/en/#invoice-creation-on-email) - The method to generate a payment link and sending it to a payer's email.

  ```ruby
  CloudPay.client.orders.create(params)
  # or
  ns = CloudPay::Orders.new
  ns.create(params)
  ```

- [Created Invoice Cancellation](https://developers.cloudpayments.ru/en/#created-invoice-cancellation) - The method to create invoice cancellation.

  ```ruby
  CloudPay.client.orders.cancel(id)
  # or
  ns = CloudPay::Orders.new
  ns.cancel(id)
  ```

- [View of Notification Settings](https://developers.cloudpayments.ru/en/#view-of-notification-settings) - The method to view notification settings.

  ```ruby
  CloudPay.client.notifications.get(type)
  # or
  ns = CloudPay::Notifications.new
  ns.get(type)
  ```

- [Change of Notification Settings](https://developers.cloudpayments.ru/en/#change-of-notification-settings) - The method to change notification settings.

  ```ruby
  CloudPay.client.notifications.update(type, params)
  # or
  ns = CloudPay::Notifications.new
  ns.update(type, params)
  ```

- [Start of Apple Pay Session](https://developers.cloudpayments.ru/en/#start-of-apple-pay-session) - Start of a session is required to take payments via Apple Pay on Web.

  ```ruby
  CloudPay.client.apple_pay.start_session(params)
  # or
  ns = CloudPay::ApplePay.new
  ns.start_session(params)
  ```

- [CloudKassir: Register Fiscalization](https://developers.cloudkassir.ru/en/#register-fiscalization) - The method of launching a cash register to the fiscal operation mode.

  ```ruby
  CloudPay.client.kassir.fiscalize(params)
  # or
  ns = CloudPay::Kassir.new
  ns.fiscalize(params)
  ```

- [CloudKassir: Online Receipt Generation](https://developers.cloudkassir.ru/en/#online-receipt-generation) - Method of an online receipt generation.

  ```ruby
  CloudPay.client.kassir.receipt.create(params)
  # or
  ns = CloudPay::Kassir::Receipt.new
  ns.create(params)
  ```

- [CloudKassir: Receipt Status Request](https://developers.cloudkassir.ru/en/#receipt-status-request) - Method of getting the receipt status.

  ```ruby
  CloudPay.client.kassir.receipt.status(id)
  # or
  ns = CloudPay::Kassir::Receipt.new
  ns.status(id)
  ```

- [CloudKassir: Receipt Details Request](https://developers.cloudkassir.ru/en/#receipt-details-request) - Method of getting the receipt details.

  ```ruby
  CloudPay.client.kassir.receipt.get(id)
  # or
  ns = CloudPay::Kassir::Receipt.new
  ns.get(id)
  ```

- [CloudKassir: Cash Register State Change](https://developers.cloudkassir.ru/en/#cash-register-state-change) - The method of manual control of the state of the cash register. The cash register can be turned off (for maintenance) and activated (put into operation).

  ```ruby
  CloudPay.client.kassir.state.update(params)
  # or
  ns = CloudPay::Kassir::State.new
  ns.update(params)
  ```

- [CloudKassir: Receiving Cash Register Data](https://developers.cloudkassir.ru/en/#receiving-cash-register-data) - Method of receiving cash register data.

  ```ruby
  CloudPay.client.kassir.state.get(params)
  # or
  ns = CloudPay::Kassir::State.new
  ns.get(params)
  ```

### Webhooks

*- Coming soon -*

## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/undr/cloud_pay.
