struct DualNumber
    real::Number
    dual::Number
end

Base.:+(dnum1::DualNumber, dnum2::DualNumber) = DualNumber(dnum1.real + dnum2.real, dnum1.dual + dnum2.dual)
Base.:+(dnum::DualNumber, num::Number) = DualNumber(dnum.real + num, dnum.dual)
Base.:+(num::Number, dnum::DualNumber) = Base.:+(dnum::DualNumber, num::Number)

Base.:-(dnum1::DualNumber, dnum2::DualNumber) = DualNumber(dnum1.real - dnum2.real, dnum1.dual - dnum2.dual)
Base.:-(dnum::DualNumber, num::Number) = DualNumber(dnum.real - num, dnum.dual)
Base.:-(num::Number, dnum::DualNumber) = DualNumber(num - dnum.real, dnum.dual)

Base.:*(dnum1::DualNumber, dnum2::DualNumber) = DualNumber(dnum1.real * dnum2.real, (dnum1.dual * dnum2.real) + (dnum1.real * dnum2.dual))
Base.:*(dnum::DualNumber, num::Number) = DualNumber(dnum.real * num, dnum.dual * num)
Base.:*(num::Number, dnum::DualNumber) = Base.:*(dnum::DualNumber, num::Number)

function Base.:/(dnum1::DualNumber, dnum2::DualNumber) 
    if dnum2.real == 0
        throw(DivideError())
    else
        return DualNumber(dnum1.real / dnum2.real, (dnum1.dual * dnum2.real - dnum1.real * dnum2.dual) / (dnum2.real ^ 2))
    end
end

function Base.:/(dnum::DualNumber, num::Number)
    if num == 0
        throw(DivideError())
    else
        return DualNumber(dnum.real / num, dnum.dual / num)
    end
end

function Base.:/(num::Number, dnum::DualNumber)
    if dnum.real == 0
        throw(DivideError())
    else
        return DualNumber(num / dnum.real, -(num * dnum.dual) / (dnum.real ^ 2))
    end
end

Base.:^(dnum1::DualNumber, dnum2::DualNumber) = DualNumber(dnum1.real ^ dnum2.real, dnum1.real ^ (dnum2.real - 1) * (dnum1.real * dnum2.dual * log(dnum1.real) + (dnum2.real * dnum1.dual)))
Base.:^(dnum::DualNumber, num::Number) = DualNumber(dnum.real ^ num, dnum.dual * num * (dnum.real ^ (num - 1)))
Base.:^(num::Number, dnum::DualNumber) = DualNumber(num ^ dnum.real, (num ^ dnum.real) * dnum.dual * log(num))

Base.:(==)(dnum1::DualNumber, dnum2::DualNumber) = (dnum1.real, dnum1.dual) == (dnum2.real, dnum2.dual)
Base.:(==)(dnum::DualNumber, num::Number) = (dnum.real, dnum.dual) == (num, 0)
Base.:(==)(num::Number, dnum::DualNumber) = Base.:==(dnum::DualNumber, num::Number)

Base.:(!=)(dnum1::DualNumber, dnum2::DualNumber) = (dnum1.real, dnum1.dual) != (dnum2.real, dnum2.dual)
Base.:(!=)(dnum::DualNumber, num::Number) = (dnum.real, dnum.dual) != (num, 0)
Base.:(!=)(num::Number, dnum::DualNumber) = Base.:!=(dnum::DualNumber, num::Number)

Base.:<(dnum1::DualNumber, dnum2::DualNumber) = (dnum1.real < dnum2.real) | ((dnum1.real == dnum2.real) & (dnum1.dual < dnum2.dual))
Base.:<(dnum::DualNumber, num::Number) = (dnum.real < num) | ((dnum.real == num) & (dnum.dual < 0))
Base.:<(num::Number, dnum::DualNumber) = (num < dnum.real) | ((num == dnum.real) & (dnum.dual > 0))
Base.:>(dnum1::DualNumber, dnum2::DualNumber) = Base.:<(dnum2::DualNumber, dnum1::DualNumber)
Base.:>(dnum::DualNumber, num::Number) = Base.:<(num::Number, dnum::DualNumber)
Base.:>(num::Number, dnum::DualNumber) = Base.:<(dnum::DualNumber, num::Number)

Base.:(<=)(dnum1::DualNumber, dnum2::DualNumber) = Base.:<(dnum1::DualNumber, dnum2::DualNumber) | Base.:(==)(dnum1::DualNumber, dnum2::DualNumber)
Base.:(<=)(dnum::DualNumber, num::Number) = Base.:<(dnum::DualNumber, num::Number) | Base.:(==)(dnum::DualNumber, num::Number)
Base.:(<=)(num::Number, dnum::DualNumber) = Base.:<(num::Number, dnum::DualNumber) | Base.:(==)(num::Number, dnum::DualNumber)
Base.:(>=)(dnum1::DualNumber, dnum2::DualNumber) = Base.:>(dnum1::DualNumber, dnum2::DualNumber) | Base.:(==)(dnum1::DualNumber, dnum2::DualNumber)
Base.:(>=)(dnum::DualNumber, num::Number) = Base.:>(dnum::DualNumber, num::Number) | Base.:(==)(dnum::DualNumber, num::Number)
Base.:(>=)(num::Number, dnum::DualNumber) = Base:>(num::Number, dnum::DualNumber) | Base.:(==)(num::Number, dnum::DualNumber)